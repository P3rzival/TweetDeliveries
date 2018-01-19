require 'sinatra'
require 'twitter'
require 'sinatra/reloader'
set bind: '0.0.0.0'

require 'sqlite3' 




include ERB::Util

before do
  config = {
     :consumer_key => '2Sr1m3AcapBgEQQQqg8vgLwLb',
    :consumer_secret => 'ECieYz1aznZ3CIlISuM1VBcEKqguj4YR99S81MDXL6h5fr0ou6',
    :access_token => '841378556517240832-wQgd24X6KachbBPz1vwjzlsG52tupkv',
    :access_token_secret => '62bGEWz4tLuWSxjoNPUzc8QGzAhdX8TgjOkSJfu7sqTgT'
}
    
    @client = Twitter::REST::Client.new(config)
     @db = SQLite3::Database.new './customers.sqlite'
end

get '/order' do
  @tweets = @client.mentions_timeline
  @collect_tweets = Array.new
  @delivery_tweets = Array.new

  @tweets.each do |tweet|
    if tweet.text.include?("#order") && tweet.text.include?("#collect")
      @collect_tweets.push(tweet)
    elsif tweet.text.include?("#order") && tweet.text.include?("#delivery")
      @delivery_tweets.push(tweet)
       @address_line1 = @db.get_first_value('select address_line1 from customers where twitter_handle = ?',[tweet.user.screen_name]) 
       @address_line2 = @db.get_first_value('select address_line2 from customers where twitter_handle = ?',[tweet.user.screen_name]) 
       @postcode = @db.get_first_value('select postcode from customers where twitter_handle = ?',[tweet.user.screen_name]) 
       @address = "#{@address_line1}, #{@address_line2}, #{@postcode}"
    end
    check = @client.friendship?('Spicy_Slice_Piz', tweet.user.screen_name)
    if check == false && tweet.user.screen_name != 'Spicy_Slice_Piz'
      @client.follow(tweet.user.screen_name)
    end
  end

  erb :order
end

post '/confirmation' do
    @content = "We're glad you're using our service! Please confirm your order by writting the # the you previously used and a yes or no! ;)"
    @user_name = params[:user].to_s
    @info = params[:id]
    @client.update("@" + @user_name + ", " + @content, in_reply_to_status_id: @info)
  erb :replied
end

post '/replied' do
  unless params[:reply].nil?
      @content = params[:reply].to_s
      @user_name = params[:user].to_s
      @info = params[:id]
      @client.update("@" + @user_name + ", " + @content, in_reply_to_status_id: @info)
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
  @tweets = @client.mentions_timeline
  @question_tweets = Array.new

  @tweets.each do |tweet|
    if tweet.text.include?("#question")
      @question_tweets.push(tweet)
    end
  end
  erb :question
end
