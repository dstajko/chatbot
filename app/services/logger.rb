class Logger
  def initialize(tool_name)
    @tool_name = tool_name
  end

  def info(message)
    Rails.logger.info("[LOGGER][#{tool_name}]: #{message}")
  end

  def error(message)
    Rails.logger.error("[LOGGER][#{tool_name}]: #{message}")
  end
end
