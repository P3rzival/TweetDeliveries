
require 'twitter'
require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'geocoder'
set :bind,  '0.0.0.0'

include ERB::Util
enable :sessions
set :session_secret, 'super secret'

ADMIN_CREDENTIAL = 'admin'
SECRET_PASSWORD = 'pizzarules2017'
SHOP_ADDRESS_SHEFFIELD = '32 Leavygreave Rd, Sheffield, S3 7RD' # Diamond as shop address
SHOP_ADDRESS_LONDON = 'London, SW1A 2BJ' # St James Park as shop address
SHEFFIELD_COOR = Geocoder.coordinates(SHOP_ADDRESS_SHEFFIELD)
LONDON_COOR = Geocoder.coordinates(SHOP_ADDRESS_LONDON)
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
    config = {
    :consumer_key => '2Sr1m3AcapBgEQQQqg8vgLwLb',
    :consumer_secret => 'ECieYz1aznZ3CIlISuM1VBcEKqguj4YR99S81MDXL6h5fr0ou6',
    :access_token => '841378556517240832-wQgd24X6KachbBPz1vwjzlsG52tupkv',
    :access_token_secret => '62bGEWz4tLuWSxjoNPUzc8QGzAhdX8TgjOkSJfu7sqTgT'
}
    
    @client = Twitter::REST::Client.new(config)
    
      
end

get '/' do
    redirect '/index'
end

get '/index' do
    session.clear
    erb:index
end

get '/menu' do
    session.clear
    erb:menu
end

get '/aboutUs' do
    session.clear
    erb:aboutUs
end

get '/contactUs' do
    session.clear
    erb:contactUs
end

get '/registration_page' do
    session.clear
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
    @pizzeria_adress = params[:pizzeria_address].strip
    @twitter_ok = !@twitter_handle.nil?
    @password_ok = @password == @re_enter && !@password.nil?
    @address_ok = !@address_line1.nil? && !@postcode.nil? 
    @contact_ok = !@contact_number.nil? && @contact_number.length == 11
    @all_ok = @password_ok && @address_ok && @contact_ok && @twitter_ok
    if @all_ok then
        @db.execute(
            'INSERT INTO customers VALUES(?,?,?,?,?,?,?)',
            [@twitter_handle,@password,@address_line1,@address_line2,@postcode,@contact_number,@pizzeria_address])
        redirect '/login_page'
    end
    erb:registration_page
end
    
get '/login_page' do
    session.clear
    @submitted = false
    erb :login_page
end

post '/login_page' do
    
    @submitted = true
    @twitter_handle2 = params[:twitter_handle2].strip
    @password2 = params[:password2].strip
    if @twitter_handle2 == ADMIN_CREDENTIAL && @password2 == SECRET_PASSWORD then
        session[:admin] = 'yes'
        redirect '/order'
    end
    session[:handle] = @twitter_handle2
    @result = @db.get_first_value('select password from customers where twitter_handle = ?',[@twitter_handle2])
    if @result == @password2 then
        redirect '/profile'
    end
    erb :login_page
end
    
get '/profile' do
    if session[:handle].nil? then
        redirect '/login_page'
    end
  
    @twitter_handle = session[:handle]
    session[:address_line1] = @db.get_first_value('select address_line1 from customers where twitter_handle = ?',[@twitter_handle])
    session[:address_line2] = @db.get_first_value('select address_line2 from customers where twitter_handle = ?',[@twitter_handle])
    session[:postcode] = @db.get_first_value('select postcode from customers where twitter_handle = ?',[@twitter_handle])
    session[:contact_number] = @db.get_first_value('select contact_number from customers where twitter_handle = ?',[@twitter_handle])
    session[:pizzeria_address] = @db.get_first_value('select City from customers where twitter_handle = ?',[@twitter_handle])    
    address = "#{session[:address_line1]}, #{session[:address_line2]}, #{session[:postcode]}"
    address_coor = Geocoder.coordinates(address)
    if session[:pizzeria_address] == "London" 
        shop = LONDON_COOR
    end
    if session[:pizzeria_address] == "Sheffield" 
        shop = SHEFFIELD_COOR    
    end    
    @distance = Geocoder::Calculations.distance_between(shop, address_coor) 
    erb :profile
end

get '/change' do
    @pass_change = false
    erb:change
end

get '/change_pass' do
    @pass_change = true
    erb:change
end

post '/change' do
    @twitter_handle = params[:twitter_handle].strip
    @address_line1 = params[:address_line1].strip
    @address_line2 = params[:address_line2].strip
    @postcode = params[:postcode].strip
    @contact_number = params[:contact_number].strip
    @pizzeria_address = params[:pizzeria_address].strip
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
    if @contact_number != '' && @contact_number.length == 11 then
        @db.execute('update customers set contact_number= ? where twitter_handle = ?', [@contact_number, session[:handle]])
    end
    if @pizzeria_address != '' then
        @db.execute('update customers set City = ? where twitter_handle = ?',[@pizzeria_address,session[:handle]])
    end    
    session.clear
    redirect 'login_page'
end

post '/change_pass' do
  password = params[:new_pass]
  re_enter = params[:confirm_new]
  confirm = params[:confirm]
        puts password
        puts re_enter
  @password_ok = password == re_enter && !password.nil?
  if @password_ok && confirm == "Confirm changes"
      @db.execute("update customers set password = ? where twitter_handle = ?", [password, session[:handle]])
      redirect 'login_page'
  elsif confirm == "Cancel"
      redirect 'profile'
  end
  erb:change
end

get '/order' do
  i=0
  if session[:admin] != 'yes' then
      redirect '/index'
  end
  @tweets = @client.mentions_timeline
      
  session[:current_city] = params[:pizzeria_address]    
  if session[:current_city] == nil   
    session[:current_city] = 'Sheffield'
  end   
  @tweets.each do |tweet|
    
    if @db.get_first_value('select * from tweets where twitter_id = ?',[tweet.id]) != nil
        break
    end
    i=i+1    
    check = @client.friendship?('Spicy_Slice_Piz', tweet.user.screen_name)
    if check == false && tweet.user.screen_name != 'Spicy_Slice_Piz'
      @client.follow(tweet.user.screen_name)
    end
    
  end   

  counter=i
  i=@db.get_first_value('SELECT MAX(id) FROM tweets')
  if i==nil
      i=0
  end    
  j=i+counter
  @tweets.each do |tweet|
    if counter == 0
        break
    end    
    if tweet.text.include?("#delivery")
        type = 'delivery'
    elsif tweet.text.include?("#collect")
        type = 'collect'
    elsif tweet.text.include?("#question")
        type = 'question'
    else type = 'other'
    end
    city=@db.get_first_value('SELECT City FROM customers where twitter_handle=?',[tweet.user.screen_name])
    @db.execute(
            'INSERT INTO tweets VALUES(?,?,?,?,?,?,?,?)',
            [i+counter,tweet.user.screen_name,tweet.text,Time.now.to_s,'no',city,type,tweet.id])
    counter=counter-1
   
    
  end      
  @collect_tweets = Array.new  
  @delivery_tweets = Array.new
  (1..j).each do |a|
    if @db.get_first_value('SELECT type FROM tweets where id=?',[a]) == 'delivery' && @db.get_first_value('SELECT completion FROM tweets where id=?',[a]) == 'no' && @db.get_first_value('SELECT city FROM tweets where id=?',[a]) == session[:current_city]
        @delivery_tweets.push(a)
    end
    if @db.get_first_value('SELECT type FROM tweets where id=?',[a]) == 'collect' && @db.get_first_value('SELECT completion FROM tweets where id=?',[a]) == 'no' && @db.get_first_value('SELECT city FROM tweets where id=?',[a]) == session[:current_city]
        @collect_tweets.push(a)
    end    
  end
  session[:tweets_total]=j      
  @delivery_tweets.reverse! 
  @collect_tweets.reverse!
  erb :order
end        

get '/confirmed' do
  if session[:logged_in] == false then
      redirect '/index'
  end
  
  session[:current_city] = params[:pizzeria_address]    
  if session[:current_city] == nil   
    session[:current_city] = 'Sheffield'
  end    
      
  @tweets = @client.mentions_timeline
  @confirmed_tweets = Array.new
  i=session[:tweets_total] 
  (1..i).each do |a|
    if @db.get_first_value('SELECT completion FROM tweets where id=?',[a]) == 'yes'
        @confirmed_tweets.push(a)
    end    
  end
  @confirmed_tweets.reverse!      
  erb :confirmed
end        
        
post '/confirmation' do
    @content = "Your order has been confirmed."
    @user_name = params[:user].to_s
    @info = params[:id]
    @db.execute('update tweets set completion=? where twitter_id=?',['yes',@info])
    @client.update("@" + @user_name + " " + @content, in_reply_to_status_id: @info)
  erb :replied
end

post '/replied' do
  unless params[:reply].nil?
      @content = params[:reply].to_s
      @user_name = params[:user].to_s
      @info = params[:id]
      @client.update("@" + @user_name + " " + @content, in_reply_to_status_id: @info)
    end
  erb :replied
end

post '/search' do
  @tweets = @client.mentions_timeline
  @user_collect_tweets = Array.new
  @user_delivery_tweets = Array.new

  @tweets.each do |tweet|
    if params[:username] == tweet.user.screen_name
      if tweet.text.include?("#order") && tweet.text.include?("#collect")
        @user_collect_tweets.push(tweet)
      elsif tweet.text.include?("#order") && tweet.text.include?("#delivery")
        @user_delivery_tweets.push(tweet)
      @address_line1 = @db.get_first_value('select address_line1 from customers where twitter_handle = ?',[tweet.user.screen_name]) 
      @address_line2 = @db.get_first_value('select address_line2 from customers where twitter_handle = ?',[tweet.user.screen_name]) 
      @postcode = @db.get_first_value('select postcode from customers where twitter_handle = ?',[tweet.user.screen_name]) 
      @address = "#{@address_line1}, #{@address_line2}, #{@postcode}"
      end
    end
  end
  erb :search
end

get '/question' do
  if session[:logged_in] == false then
      redirect '/index'
  end
  @tweets = @client.mentions_timeline
  @question_tweets = Array.new

  @tweets.each do |tweet|
    if tweet.text.include?("#question")
      @question_tweets.push(tweet)
    end
  end
  erb :question
end