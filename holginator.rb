require_relative './lib/holginator/sinatra_helper'

require 'sinatra'
require 'json'
require 'redis'



helpers ::Holginator::SinatraHelper
set :public_folder, 'public'

configure do
  set :logging, true
  if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    $redis = Redis.new
  end
end

get '/' do
  erb :index
end

get '/:feed.xml' do
  key  = "holginator:#{params[:feed]}"
  feed = $redis.get(key)
  if feed
    content_type "application/rss+xml"
    log_request
    etag etag_for_feed
    feed

  else
    status 404
  end
end

get '/:feed/stats.json' do 
  stats_for_api.to_json
end

get '/:feed/stats' do 
  @year  = Time.now.year
  @monthly_stats = aggregate_stats
  @feed_name = params[:feed].to_s
  erb :stats
end
