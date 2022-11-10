require "sinatra"

class App < Sinatra::Base
  get "/" do
    "Hello. This is RequestSink!"
  end

  %w(post put patch delete).each do |method|
    send method, "/*" do
      <<~DEBUG
        request_path: #{request.path_info}
        request.request_method: #{request.request_method}
        request.env[CONTENT_TYPE]: #{request.env["CONTENT_TYPE"]}
        request.body: #{request.body.read}
      DEBUG
    end
  end
end

