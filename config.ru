require './app'
require './middlewares/messenger'

use Notification::Messenger

run Notification::App
