
class EventTracker
  # This is an abstraction to track events in your application
  # For example, you might want to log the event to a database or an analytics service
  def initialize(tool_name)
    @tool_name = tool_name
  end

  def track_event(status, params = {})
    # Here you can implement the logic to track the event (e.g., log to a database)
    # For example, you might want to log the event to a database or an analytics service
    Rails.logger.info("[ANALYTICS][#{@tool_name}]: status: #{status}, params: #{params}")
  end
end
