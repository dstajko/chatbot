class Logger
  def initialize(name)
    @tool = name
  end

  def info(message)
    Rails.logger.info("[LOGGER][#{tool}]: #{message}")
  end

  def error(message)
    Rails.logger.error("[LOGGER][#{tool}]: #{message}")
  end
end
