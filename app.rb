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

  def set_target_url
    @target_url = [ENV["FORWARD_TO"], request.path_info].join
  end

  def set_headers
    @headers = {
      'Content-Type' => request.env["CONTENT_TYPE"]
    }
    extra_headers = ENV["FORWARD_HEADERS"].to_s.split(' ')
    extra_headers.each do |key|
      @headers[key] = request.env["HTTP_#{key}"]
    end
  end

  def forward(method, body = nil)
    HTTParty.send(
      method,
      @target_url,
      body: body,
      headers: @headers
    )
  end

  ENV["GET_PATHS"]&.split(' ')&.each do |path|
    get path do
      set_target_url
      set_headers

      resp = forward "get"

      status resp.code
      content_type resp.content_type

      puts <<~LOG
        #{request.user_agent.italic.gray}
          #{request.request_method.bold} #{@target_url}
          #{resp.code.to_s.yellow}
      LOG

      if resp.headers["www-authenticate"]
        response.headers["Www-Authenticate"] = Array(resp.headers["www-authenticate"]).first
      end

      resp.body if resp.code < 300
    end
  end

  %w(post put patch delete).each do |method|
    send method, "/*" do
      set_target_url
      set_headers
      request_body = request.body.read

      resp = forward method, request_body

      status resp.code

      puts <<~LOG
        #{request.user_agent.italic.gray}
          #{request.request_method.bold} #{@target_url.italic}
          #{@headers.to_s.blue}
          #{request_body}
          #{resp.code.to_s.yellow}
      LOG

      if resp.headers["www-authenticate"]
        response.headers["Www-Authenticate"] = Array(resp.headers["www-authenticate"]).first
      end

      # If resp succeeded return the body too
      # otherwise hide the body, to not leak error backtraces or similar sensitive content.
      resp.body if resp.code < 300
    end
  end
end

