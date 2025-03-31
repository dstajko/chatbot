require "httparty"

class WeatherTool < Tool
  NAME = "WEATHER_TOOL"

  def initialize(user_input, sse)
    # Assume city is the last word in the query
    @city = user_input.split.last
    @sse = sse
    @logger = Logger.new(NAME)
    @event_tracker = EventTracker.new(NAME)
  end

  def execute
    response = HTTParty.get(url)

    message =
      if response.nil?
        @event_tracker.track_event(status: :failure, params: { city: @city, response_code: response.code })
        @logger.error("Failed to fetch weather for #{@city}")
        "Sorry, I couldn't retrieve the weather for #{@city}."

      elsif response.code == 200
        @event_tracker.track_event(status: :success, params: { city: @city })
        @logger.info("Successfully fetched weather for #{@city}")
        data = response.parsed_response
        temp = data.dig("main", "temp")
        description = data.dig("weather", 0, "description")
        "WeatherTool: The current weather in #{@city} is #{temp}°C with #{description}."

      elsif response.code == 400
        @event_tracker.track_event(status: :failure, params: { city: @city, response_code: response.code, message: response.body })
        @logger.error("Failed to fetch weather for #{@city}")
        "Could not find any city with that name: #{@city}. Please try again with a valid city."
      else
        @event_tracker.track_event(status: :failure, params: { city: @city, response_code: response.code, message: response.body })
        @logger.error("Failed to fetch weather for #{@city}")
        "Sorry, I couldn't retrieve the weather for #{@city}."
      end

    @sse.write({ message: message })
  rescue => exception
    @event_tracker.track_event(status: :failure, params: { city: @city, exception_type: exception.class.name, exception_message: exception.message })
    @logger.error("Exception occurred while fetching weather for #{@city}: #{exception.message}")
    @sse.write({ message: "Sorry, I couldn't retrieve the weather for #{@city} due to an error." })
  end

  private

  def url
    api_key = ENV["WEATHER_API_KEY"]
    "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&appid=#{api_key}&units=metric"
  end
end
