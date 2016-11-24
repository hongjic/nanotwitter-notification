require 'redis'
require 'active_record'
require 'singleton'

require './models/notification'

module NotificationService
  class NoteBuilder
    include Singleton

    CHANNEL = "notification"
    attr_accessor :redis

    def initialize 
      uri = URI.parse(ENV["REDIS_URL"])
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end

    def exec_task method, params
      instance_eval("#{method} params")
    end

    def build note_info
      begin
        note = Notification.new
        # create note_info
        note.target_user_id = note_info["target_user_id"]
        note.type = note_info["type"]
        note.tweet_id = note_info["tweet_id"]
        note.new_follower_id = note_info["new_follower_id"]
        note.save
        if note_info["type"] == "new_follower"
          message = note_info["source_user_name"] + " has followed you."
        elsif note_info["type"] == "reply"
          message = note_info["source_user_name"] + " gived you a reply."
        else 
          message = note_info["mention"] + " mentioned you."
        end
        msg = {
          target: note_info["target_user_id"],
          source: note_info["source_user_name"],
          message: message 
        }
        @redis.publish(CHANNEL, msg.to_json) # msg {source, target, message}
        puts "publish finish"
        true
      rescue ActiveModel::UnknownAttributeError, ActiveRecord::InvalidForeignKey
        false
      end

    end

  end
end