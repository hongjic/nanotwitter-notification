require 'bunny'

require './config/db_environment'
require './workers/notification_builder'

require 'byebug'

connection_config = ENV["RABBITMQ_BIGWIG_URL"]
conn = Bunny.new(connection_config)
conn.start

ch = conn.create_channel
q = ch.queue("notification:create")
notebuilder = NotificationService::NoteBuilder.instance

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    # body needs {target_user_id, type, tweet_id, new_follower_id, source_user_name}
    note_info = JSON.parse body
    puts "a"
    notebuilder.build note_info
  end
rescue Interrupt => _
  puts "Interrupt "
  conn.close
  exit(0)
end