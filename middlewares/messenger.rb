require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'
require 'byebug'

# url path: => username
# websocket push msg = {source: "user", target: "user", message: "user"}
# in redis: {source: "user", target: "user", message: "user"}

module Notification
  class Messenger
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "notification"

    def initialize(app)
      @app     = app
      @clients = {}
      uri = URI.parse(ENV["REDIS_URL"])
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      Thread.new do
        redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        redis_sub.subscribe(CHANNEL) do |on|
          on.message do |channel, msg_str| 
            msg = deserialize msg_str
            target = msg["target"]
            message = msg["message"]
            @clients[target].send msg.to_json if @clients.has_key? target
          end
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients.store ws.env["REQUEST_PATH"][1..-1], ws 
        end

        ws.on :message do |event|
          p [:message, event.data]
          # event.data = a JSON string {source: "user", target: "user", message: "message"}
          msg = deserialize(event.data)
          msg["source"] = ws.env["REQUEST_PATH"][1..-1]
          @redis.publish(CHANNEL, msg.to_json)
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete(ws.env["REQUEST_PATH"][1..-1])
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private
      def deserialize(data)
        json = JSON.parse(data)
      end
  end
end
