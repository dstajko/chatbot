require_dependency "chat_bot_service"

class ChatResponsesController < ApplicationController
  include ActionController::Live

  def show
    prompt = params[:prompt]
    sse = init_sse_for_message

    begin
      ::ChatBotService.new(prompt, sse).run
    ensure
      sse.close
    end
  end

  private

  def init_sse_for_message
    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Last-Modified"] = Time.now.strftime("%a, %d %b %Y %H:%M:%S GMT")
    SSE.new(response.stream, event: "message")
  end
end
