module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      '/index'
        
    when /the registration_page/
        '/registration_page'

    when /the login_page/
        '/login_page'
        
    when /the order_page/
        '/order'
    
     when /the account_page/
        '/account_page'
       
     when /the search page/
        '/search'
        
     when /the question page/
        '/question'
        
     when /the confirmed_page/
        '/confirmed'
        
     when /the confirmation_page/
        'confirmation'
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"

    end
  end
end

World(NavigationHelpers)