require "sinatra"
require "httparty"

if ENV["FORWARD_TO"].nil?
  raise StandardError, "FORWARD_TO enviroment variable must be specified."
else
  puts
  puts "Requests will be forwarded to #{ENV["FORWARD_TO"]}"

  if ENV["FORWARD_HEADERS"]
    puts "Extra headers to forward: #{ENV["FORWARD_HEADERS"]}"
  end

  puts
end

class App < Sinatra::Base
  get "/" do
    "Hello. This is RequestSink!"
  end

  %w(post put patch delete).each do |method|
    send method, "/*" do
      target_url = [ENV["FORWARD_TO"], request.path_info].join
      puts "Forwarding #{request.request_method} request from #{request.user_agent} to #{target_url}"

      headers = {
        'Content-Type' => request.env["CONTENT_TYPE"]
      }
      extra_headers = ENV["FORWARD_HEADERS"].to_s.split(' ')
      extra_headers.each do |key|
        headers[key] = request.env["HTTP_#{key}"]
      end

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

