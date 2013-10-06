require 'sinatra'

set :public_folder, 'public'

get '/' do
  "Holginator!"
  erb :index
end

get '/:feed.xml' do
  content_type "application/rss+xml"
  send_file File.join(settings.public_folder, "#{params[:feed]}.xml")
end
