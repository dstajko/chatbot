require 'test_helper'

class LlmToolTest < ActiveSupport::TestCase
  def setup
    @user_input = "What is the weather today?"
    @llm_tool = LlmTool.new(@user_input)
    @mock_sse = Minitest::Mock.new
  end

  test "should stream content when OpenAI client responds successfully" do
    # Mock OpenAI client response
    mock_client = Minitest::Mock.new
    mock_client.expect(:chat, nil) do |parameters|
      stream_proc = parameters[:parameters][:stream]
      # Simulate streaming chunks
      stream_proc.call({ "choices" => [{ "delta" => { "content" => "Hello" } }] })
      stream_proc.call({ "choices" => [{ "delta" => { "content" => " World!" } }] })
    end

    OpenAI::Client.stub(:new, mock_client) do
      @mock_sse.expect(:write, nil, [{ message: "Hello" }])
      @mock_sse.expect(:write, nil, [{ message: " World!" }])

      @llm_tool.execute(@mock_sse)
    end

    assert_mock @mock_sse
    assert_mock mock_client
  end

  test "should handle exceptions and write error message to SSE" do
    # Mock OpenAI client to raise an exception
    mock_client = Minitest::Mock.new
    mock_client.expect(:chat, nil) { raise StandardError.new("API error") }

    OpenAI::Client.stub(:new, mock_client) do
      @mock_sse.expect(:write, nil, [{ message: "Sorry, I couldn't answer  you due to an error." }])

      @llm_tool.execute(@mock_sse)
    end

    assert_mock @mock_sse
    assert_mock mock_client
  end

  test "should track success event when execution succeeds" do
    # Mock OpenAI client response
    mock_client = Minitest::Mock.new
    mock_client.expect(:chat, nil) do |parameters|
      stream_proc = parameters[:parameters][:stream]
      stream_proc.call({ "choices" => [{ "delta" => { "content" => "Test" } }] })
    end

    OpenAI::Client.stub(:new, mock_client) do
      EventTracker.stub(:track_event, nil) do |event_name, params|
        assert_equal "Llm", event_name
        assert_equal :success, params[:status]
      end

      @mock_sse.expect(:write, nil, [{ message: "Test" }])
      @llm_tool.execute(@mock_sse)
    end
  end
end