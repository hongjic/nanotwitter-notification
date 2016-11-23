require 'eventmachine'
require 'websocket-eventmachine-server'
require 'byebug'
 
PORT = ENV["WEBSOCKET_PORT"] || 5000

EM::run do
  
  puts "start websocket server - port:#{PORT}"

  WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => PORT) do |ws|

    ws.onopen do

      @channel = EM::Channel.new

      sid = @channel.subscribe do |mes|
        ws.send mes
      end
      puts "<#{sid}> connect"

      @channel.push "hello new client <#{sid}>"

      ws.onmessage do |msg|
        puts "<#{sid}> #{msg}"
        @channel.push "<#{sid}> #{msg}"
      end

      ws.onclose do
        puts "<#{sid}> disconnected"
        @channel.unsubscribe sid
        @channel.push "<#{sid}> disconnected"
      end
    end
  end

end
