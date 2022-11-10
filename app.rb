require "sinatra"

class App < Sinatra::Base
  get "/" do
    "Hello. This is RequestSink!"
  end
end

