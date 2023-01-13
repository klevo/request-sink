require "sinatra"
require "httparty"
require "colorize"

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
      request_body = request.body.read

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
        body: request_body,
        headers: headers
      )

      status response.code

      puts <<~LOG
        #{request.request_method.red} #{request.user_agent.italic}
        #{request_body}
        #{target_url.green} #{response.code.to_s.yellow}
      LOG
    end
  end
end

