Feature: login

  Scenario: Correct confirmation of password
    Given I am on the login_page
    When I fill in "twitter_handle2" with "admin"
    When I fill in "password2" with "pizzarules2017"
    Then I am on the order_page
    
   Scenario: Wrong confirmation of password
    Given I am on the login_page
    When I fill in "twitter" with "nonsense"
    When I fill in @password2 with @result
    When I press "login"
    Then I am on the account_page
    
  Scenario: Working properly
    Given I am on the login_page
    When I press "Home"
    Then I am on the homepage
    
  Scenario: Getting to the login page
    Given I am on the homepage
    When I follow "/login_page"
    Then I am on the login_page
    
  Scenario: SQL injection
    Given I am on the login_page
    When I fill in "twitter_handle2" with "admin"
    When I fill in "password2" with "' or 1=1"
    Then I am on the order_page