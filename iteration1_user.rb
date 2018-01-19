
require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'geocoder'
set :bind,  '0.0.0.0'

include ERB::Util
enable :sessions
set :session_secret, 'super secret'

SHOP_ADDRESS = '32 Leavygreave Rd, Sheffield, S3 7RD' # Diamond as shop address
SHOP_COOR = Geocoder.coordinates(SHOP_ADDRESS)

before do
    @db = SQLite3::Database.new './customers.sqlite'

    
    Geocoder.configure(
        # geocoding service
        lookup: :google,

        # geocoding service request timeout (in seconds)
        timeout: 3,
    
        #Unit in mile
        units: :mi
        
    )

end

get '/index' do
    
    erb:index
end

get '/menu' do
    erb:menu
end

get '/aboutUs' do
    erb:aboutUs
end

get '/contactUs' do
    erb:contactUs
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
    @address_ok = !@address_line1.nil? && !@postcode.nil? #&& distance <= 5
    @contact_ok = !@contact_number.nil? && @contact_number.length == 11
    @all_ok = @password_ok && @address_ok && @contact_ok && @twitter_ok
    if @all_ok then
        @db.execute(
            'INSERT INTO customers VALUES(?,?,?,?,?,?)',
            [@twitter_handle,@password,@address_line1,@address_line2,@postcode,@contact_number])
        redirect '/login_page'
    end
    erb:registration_page
end
    
get '/login_page' do
    @submitted = false
    erb :login_page
end

post '/login_page' do
    @submitted = true
    session[:handle] = params[:twitter_handle2].strip
    @twitter_handle2 = session[:handle]
    @password2 = params[:password2].strip
    @result = @db.get_first_value('select password from customers where twitter_handle = ?',[@twitter_handle2])
    if @result == @password2 then
        redirect '/account_page'
    end
    erb:login_page
end
    
get '/account_page' do
    if session[:handle].nil? then
        redirect '/login_page'
    end
    @twitter_handle = session[:handle]
    @address_line1 = @db.get_first_value('select address_line1 from customers where twitter_handle = ?',[@twitter_handle])
    @address_line2 = @db.get_first_value('select address_line2 from customers where twitter_handle = ?',[@twitter_handle])
    @postcode = @db.get_first_value('select postcode from customers where twitter_handle = ?',[@twitter_handle])
    @contact_number = @db.get_first_value('select contact_number from customers where twitter_handle = ?',[@twitter_handle])
    address = "#{@address_line1}, #{@address_line2}, #{@postcode}"
    address_coor = Geocoder.coordinates(address)
    @distance = Geocoder::Calculations.distance_between(SHOP_COOR, address_coor) 
    erb:account_page
end
    
post '/account_page' do
    @twitter_handle = params[:twitter_handle].strip
    @address_line1 = params[:address_line1].strip
    @address_line2 = params[:address_line2].strip
    @postcode = params[:postcode].strip
    if @address_line1 != '' then
        @db.execute('update customers set address_line1 = ? where twitter_handle = ?',[@address_line1,session[:handle]])
    end
    if @address_line2 != '' then
        @db.execute('update customers set address_line2 = ? where twitter_handle = ?',[@address_line2,session[:handle]])
    end
    if @twitter_handle != '' then
        @db.execute('update customers set twitter_handle = ? where twitter_handle = ?',[@twitter_handle,session[:handle]])
    end
    if @postcode != '' then
        @db.execute('update customers set postcode = ? where twitter_handle = ?',[@postcode,session[:handle]])
    end
    session.clear
    redirect 'login_page'
    erb:account_page
end
