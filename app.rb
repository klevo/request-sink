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

  ENV["GET_PATHS"].split(' ').each do |path|
    get "#{path}/*" do
      set_target_url
      set_headers

      # TODO: forward and render response
    end
  end

  %w(post put patch delete).each do |method|
    send method, "/*" do
      set_target_url
      set_headers

      request_body = request.body.read
      response = HTTParty.send(
        method,
        @target_url,
        body: request_body,
        headers: @headers
      )

      status response.code

      puts <<~LOG
        #{request.request_method.red} #{request.user_agent.italic}
        #{request_body}
        #{@target_url.green} #{response.code.to_s.yellow}
      LOG
    end
  end
end

