require 'test_helper'

class WeatherToolTest < ActiveSupport::TestCase
  def setup
    @city = "London"
    @weather_tool = WeatherTool.new(@city)
    @api_key = ENV['WEATHER_API_KEY']
  end

  test "should return weather data when API call is successful" do
    # Mock successful API response
    response_body = {
      "main" => { "temp" => 15 },
      "weather" => [{ "description" => "clear sky" }]
    }.to_json

    stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&appid=#{@api_key}&units=metric")
      .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

    result = @weather_tool.execute

    assert_equal "The current weather in London is 15°C with clear sky.", result
  end

  test "should log error and return nil when API call fails" do
    # Mock failed API response
    stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&appid=#{@api_key}&units=metric")
      .to_return(status: 404, body: "City not found")

    result = @weather_tool.execute

    assert_nil result
  end

  test "should handle exceptions and return nil" do
    # Mock exception during API call
    stub_request(:get, "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&appid=#{@api_key}&units=metric")
      .to_raise(StandardError.new("Network error"))

    result = @weather_tool.execute

    assert_nil result
  end
end