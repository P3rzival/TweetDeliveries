Feature: registration

  Scenario: Correct confirmation of password
    Given I am on the registration_page
    When I fill in "password" with "nonsense"
    When I fill in "re_enter" with "nonsense"
    When I press "Registration"
    Then I am on the login_page
    
   Scenario: Wrong confirmation of password
    Given I am on the registration_page
    When I fill in "password" with "nonsense"
    When I fill in "re_enter" with "sense"
    When I press "Registration"
    Then I am on the registration_page
    
  Scenario: wrong characters for contact_number
    Given I am on the registration_page
    When I fill in "contact_number" with "0123456789"
    When I press "Registration"
    Then I am on the registration_page
    
  Scenario: Correct characters for contact_number
    Given I am on the registration_page
    When I fill in "contact_number" with "01234567891"
    When I press "Registration"
    Then I am on the login_page
  
  Scenario: Correc input for contact_number
    Given I am on the registration_page
    When I fill in "contact_number" with "hello"
    When I press "Registration"
    Then I am on the registration_page
    
  Scenario: Home button wokring 
    Given I am on the registration_page
    When I press "Home"
    Then I am on the homepage
    
    