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

get '/account_page' do
    @twitter_handle = session[:handle]
    @address_line1 = @db.get_first_value('select address_line1 from customers where twitter_handle = ?',[@twitter_handle])
    @address_line2 = @db.get_first_value('select address_line2 from customers where twitter_handle = ?',[@twitter_handle])
    @postcode = @db.get_first_value('select postcode from customers where twitter_handle = ?',[@twitter_handle])
    @contact_number = @db.get_first_value('select contact_number from customers where twitter_handle = ?',[@twitter_handle])
    erb:account_page
end
    
post '/account_page' do
    @twitter_handle = params[:twitter_handle].strip
    @address_line1 = params[:address_line1].strip
    @address_line2 = params[:address_line2].strip
    @db.execute('update customers set twitter_handle = ?, address_line1 = ?, address_line2 = ? where twitter_handle = ?',[@twitter_handle,@address_line1,@address_line2,session[:handle]])
    redirect 'login_page'
    erb:account_page
end
