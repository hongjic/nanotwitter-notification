require './app'
require './middlewares/messenger'

use NotificationService::Messenger

run NotificationService::App
