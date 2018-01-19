require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
set :bind,  '0.0.0.0'

include ERB::Util
enable :sessions
set :session_secret, 'super secret'

before do
   @db = SQLite3::Database.new './customers.sqlite'
end

get '/login_page' do
    @submitted = false
    erb :login_page
end

post '/login_page' do
    @submitted = true
    session[:handle] = params[:twitter_handle2].strip #this line causes problems
    @twitter_handle2 = session[:handle]
    @password2 = params[:password2].strip
    @result = @db.get_first_value('select password from customers where twitter_handle = ?',[@twitter_handle2])
    if @result == @password2 then
        redirect '/account_page'
    end
    erb:login_page
end
