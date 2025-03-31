require "yaml"

class ChatBotStrategy
  def initialize
    # We could store tool configurations in a tool registry,
    # or alternatively, keep them in the database or a YML file.
    # @registered_tools = {
    #   "weather" => "WeatherTool",
    #   "mortgage calculator" => "MortgageCalculatorTool",
    #   ...
    # }
    # This would allow to design a structured way for the chatbot to decide when to use a tool versus relying on the LLM's response.
  end

  def select(user_input, sse)
    # Simple implementation to check if the user input contains "weather", no tools registry
    if user_input.downcase.include?("weather")
      city = user_input.split.last
      WeatherTool.new(city, sse)
    else
      LlmTool.new(user_input, sse)
    end
  end
end
