class LlmTool < Tool
  # LLM is a fallback strategy, meaning it will be used when no other tool or API integration is available based on the user input.

  NAME = "LLM"

  def initialize(user_input, sse)
    @user_input = user_input
    @sse = sse
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"], log_errors: true)
    @logger = Logger.new(NAME)
    @event_tracker = EventTracker.new(NAME)
  end

  def execute
    @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [ { role: "user", content:  @user_input } ],
          stream: proc do |chunk|
            content = chunk.dig("choices", 0, "delta", "content")

            next if content.nil?

            @sse.write({ message: content })
          end
        }
      )
    @event_tracker.track_event(status: :success)
  rescue => exception
    @event_tracker.track_event(status: :failure, exception_type: exception.class.name, exception_message: exception.message)
    @logger.error("An error occurred: #{exception.message}")
    @sse.write({ message: "Sorry, I couldn't answer  you due to an error." })
  end
end
