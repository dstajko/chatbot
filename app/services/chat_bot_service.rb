class ChatBotService
  # ChatBotService selects the appropriate "strategy" based on the user input and then executes it.
  def initialize(user_input, sse)
    @user_input = user_input
    @strategy = ChatBotStrategy.new.select(@user_input, sse)
  end

  def run
    @strategy.execute
  end
end
