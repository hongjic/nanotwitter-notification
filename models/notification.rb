class Notification < ActiveRecord::Base

  belongs_to :target_user, :class_name => 'User'
  belongs_to :tweet
  belongs_to :new_follower, :class_name => 'User'

  enum type: { mention: 0, reply: 1, new_follower: 2 }
  enum status: { unread: 0, read: 1 }

end