require "sinatra"
require "httparty"

if ENV["FORWARD_TO"].nil?
  raise StandardError, "FORWARD_TO enviroment variable must be specified."
else
  puts
  puts "Requests will be forwarded to #{ENV["FORWARD_TO"]}"
  puts
end

class App < Sinatra::Base
  get "/" do
    "Hello. This is RequestSink!"
  end

  %w(post put patch delete).each do |method|
    send method, "/*" do
      # <<~DEBUG
      #   request_path: #{request.path_info}
      #   request.request_method: #{request.request_method}
      #   request.env[CONTENT_TYPE]: #{request.env["CONTENT_TYPE"]}
      #   request.body: #{request.body.read}
      # DEBUG

      target_url = [ENV["FORWARD_TO"], request.path_info].join
      # TODO: Add things like API auth username & pass
      headers = { 'Content-Type' => request.env["CONTENT_TYPE"] }

      response = HTTParty.send(
        method,
        target_url,
        body: request.body.read,
        headers: headers
      )

      status response.code
    end
  end
end

