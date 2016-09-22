Feature: Activate Search

  Scenario: Getting an embed code for my affiliate site search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    Then I should see "Form Snippet"
    And I should see "Type-ahead search and DigitalGov Search Tag Snippet"
    And I should see the code for English language sites

  Scenario: Getting an embed code for my affiliate site search in Spanish
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | es     |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    Then I should see the code for Spanish language sites

  Scenario: Visiting the Site API Access Key
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | api_access_key |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | MY_AWESOME_KEY |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    And I follow "API Access Key"
    Then I should see "MY_AWESOME_KEY"

  Scenario: Visiting the Site API Instructions
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following RSS feeds:
      | name   | url                            |
      | News-1 | http://www.usa.gov/feed/news-1 |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    And I follow "Search Results API Instructions"
    Then I should see "API Instructions" within the Admin Center content

    When I follow "bought an API key from Bing or Google" within the Admin Center content
    Then I should see "Tips on How to Buy a Commercial API Key"

    When I go to the aff.gov's Activate Search page
    And I follow "Type-ahead API Instructions"
    Then I should see "Type-ahead API Instructions" within the Admin Center content

  Scenario: Visiting the Site i14y Beta API Instructions
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | gets_i14y_results |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | true              |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Activate Search page
    And I follow "i14y Beta API Instructions"
    Then I should see "i14y Beta API Instructions" within the Admin Center content
    And I should see "manage your i14y drawers"
