require "sinatra"

class App < Sinatra::Base
  get "/" do
    "Hello. This is RequestSink!"
  end

  post "/*" do
    # request.path_info
    <<~DEBUG
      request_path: #{request.path_info}
      request.env[CONTENT_TYPE]: #{request.env["CONTENT_TYPE"]}
      request.body: #{request.body.read}
    DEBUG
  end
end

