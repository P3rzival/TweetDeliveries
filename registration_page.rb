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

get '/registration_page' do
    @submitted = false
    erb:registration_page
end

post '/registration_page' do
    @submitted = true
    @twitter_handle = params[:twitter_handle].strip
    @password = params[:password].strip
    @re_enter = params[:re_enter].strip
    @address_line1 = params[:address_line1].strip
    @address_line2 = params[:address_line2].strip
    @postcode = params[:postcode].strip
    @contact_number = params[:contact_number].strip
    
    @twitter_ok = !@twitter_handle.nil?
    @password_ok = @password == @re_enter && !@password.nil?
    @address_ok = !@address_line1.nil? && !@postcode.nil?
    @contact_ok = !@contact_number.nil?# && @contact_number.length == 11
    @all_ok = @password_ok && @address_ok && @contact_ok && @twitter_ok
    if @all_ok then
        @db.execute(
            'INSERT INTO customers VALUES(?,?,?,?,?,?)',
            [@twitter_handle,@password,@address_line1,@address_line2,@postcode,@contact_number])
        redirect '/login_page'
    end
    erb:registration_page
end
