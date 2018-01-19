Feature: order

  Scenario: Page change to search page
    Given I am on the order_page
    When I fill in "username" with "tweet.user.screen_name"
    Then I am on the search page
    Then I should see "tweet.user.screen_name" within "Delivering Orders"
    
  Scenario: Page change to question page
    Given I am on the order_page
    When I follow "/questions" 
    Then I am on the question page
    
  Scenario: Page change to confirmed page
    Given I am on the order_page
    When I follow "/confirmed"
    Then I am on the confirmed_page
    
  Scenario: Click the logout button
    Given I am on the order_page
    When I follow "log out"
    Then I am on the homepage
    
  Scenario: Confirm an order
    Given I am on the order_page
    When I follow "confirmation"
    Then I am on the confirmation page
    
  Scenario: Text loads
    Given I am on the order_page
    Then I should see "Delivering Orders"
   
  Scenario: Basic Check
    Given I am on the order_page
    Then I am on the order_page
    
 