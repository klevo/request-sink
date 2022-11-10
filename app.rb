require "sinatra"

class App < Sinatra::Base
  get "/" do
    "Hello. This is RequestSink!"
  end

  get "/*" do
    # request.path_info
    <<~DEBUG
      request: #{request.inspect}
      request_path: #{request.path_info}
    DEBUG
  end
end

