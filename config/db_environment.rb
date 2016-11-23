require 'sinatra'
require 'active_record'

configure :development do
  puts "[development environment: development]"
  db = URI.parse(ENV['NT_DATABASE_URL'] || 'postgres://localhost/development')
  ActiveRecord::Base.establish_connection(
    :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8',
    :pool => 5
    )
end

configure :production do
  puts "[development environment: production]"
  db = URI.parse(ENV['DATABASE_URL'])
  ActiveRecord::Base.establish_connection(
    :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8',
    :pool => 5
    )
end