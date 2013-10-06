require 'sinatra'

set :public_folder, 'public'

configure do
  require 'redis'
  if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    $redis = Redis.new
  end
end

get '/' do
  "Holginator!"
  erb :index
end

get '/:feed.xml' do
  key  = "holginator:#{params[:feed]}"
  feed = $redis.get(key)
  if feed
    content_type "application/rss+xml"
    feed
  else
    status 404
  end
end
