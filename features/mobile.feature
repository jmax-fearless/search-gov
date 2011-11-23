Feature: Mobile Search
  In order to get government-related information on my mobile device
  As a mobile device user
  I want to be able to search with a streamlined interface

  Background:
    Given I am using a mobile device

  Scenario: Visiting the home page with a mobile device
    Given I am on the homepage
    Then I should see "INDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see a link to "Visit Our Blog" with url for "http://blog.usa.gov"
    And I should see a link to "Text/SMS Services" with url for "http://search.usa.gov/usa/sms"
    And I should see a link to "Español" with url for "http://m.gobiernousa.gov"
    And I should see a link to "USA.gov Full Site" with url for "http://www.usa.gov/?mobile-opt-out=true"
    
  Scenario: Visiting the home page with a tablet (e.g. iPad) device
    Given I am using a tablet device
    And I am on the homepage
    Then I should not see "ROBOTS" meta tag
    And I should not see "Visit Our Blog"
    And I should not see "Text/SMS Services"
    And I should not see "Español"
    And I should not see "USA.gov Full Site"

  Scenario: Visiting the Spanish home page with a mobile device
    Given I am on the Spanish homepage
    When I follow "Search in English"
    Then I should be on the homepage

  Scenario: Toggling full mode
    Given I am on the search page
    When I follow "Classic"
    Then I should be on the homepage

  Scenario: Clicking on trending searches
    Given the following Top Searches exist:
      | position | query               |
      | 1        | Hurricane iRene     |
      | 2        | Virginia Earthquake |
      | 3        | debt limit          |
    When I am on the search page
    And I follow "Classic"
    And I follow "Hurricane iRene"
    Then I should see "Results 1-10"

  Scenario: Toggling back to mobile mode
    Given I am on the search page
    When I follow "Classic"
    And I follow "Mobile"
    Then I should be on the homepage page
    And I should see "USA.gov Full Site"

  Scenario: Going to mobile mode from Spanish web homepage
    Given I am using a desktop device
    And I am on the Spanish homepage
    Then I should see a link to "Móvil" with url for "http://m.gobiernousa.gov"

  Scenario: A search on the mobile home page
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see "Social Security"
    And I should see 3 search results
    When I follow "USASearch Home"
    Then I should be on the homepage
    
  Scenario: A search on the home page from a tablet
    Given I am using a tablet device
    And I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    And I should not see "Classic | Mobile"

  Scenario: Visiting the Spanish mobile SERP
    Given I am on the Spanish homepage
    When I fill in "query" with "educación"
    And I submit the search form
    Then I should be on the search page
    And I should see "educación"
    And I should see an image link to "USASearch Home" with url for "http://m.gobiernousa.gov"

  Scenario: An advanced search on the mobile home page
    When I am on the advanced search page
    Then I should see "Use the options on this page to create a very specific search"

  Scenario: Boosted contents on the mobile site
    Given the following Boosted Content entries exist:
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title               | url                     | description                               |
      | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
      | Pelosi misspelling  | http://www.bar.gov/pel  | Synonyms file test works                  |
      | all about agencies  | http://www.bar.gov/pe2  | Stemming works                            |
    And I am on the homepage
    And I fill in "query" with "emergency"
    And I press "Search"
    Then I should be on the search page
    And I should see "Our Emergency Page"
    And I should see "FAQ Emergency Page"
    And I should not see "Our Tourism Page"
    And I should not see "Bar Emergency Page"

  Scenario: Boosted contents on the Spanish mobile site
    Given the following Boosted Content entries exist:
      | title               | url                     | description                               | locale  |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      | es      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         | es      |
      | Tour Emergency Page | http://www.aff.gov/tou  | Emergency tourism information             | en      |
    And I am on the Spanish homepage
    And I fill in "query" with "emergency"
    And I press "Search"
    And I should see "Our Emergency Page"
    And I should see "FAQ Emergency Page"
    And I should not see "Tour Emergency Page"

  Scenario: A search with results containing recalls on multiple days
    Given the following Product Recalls exist:
    |recall_number|manufacturer                   |type    |product                                                     |hazard        |country             |recalled_days_ago|
    |10155        |Graco                          |Stroller|Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller|Entrapment    |Canada              |15               |
    |10157        |Hasbro                         |Stroller|Hasbro Window Stroller                                      |Defenestration|USA                 |18               |
    |10156        |Graco, Walmart, Martha Stewart |Bed     |Graco Cozy Glow-in-the-Dark Classic Toddler Beds            |Vomiting      |USA, Vietnam, China |25               |
    |10150        |Graco                          |Stroller|Graco Neck Restraint                                        |Decapitation  |Canada              |35               |
    And I am on the homepage
    When I fill in "query" with "graco recall"
    And I submit the search form
    Then I should be on the search page
    And I should see "Graco E-Z Roller baby strollers, Graco Hard-to-Roll stroller"
    And I should see "Graco Cozy Glow-in-the-Dark Classic Toddler Beds"
    And I should not see "Hasbro Window Stroller"
    And I should not see "Graco Neck Restraint"

  Scenario: A search with auto results containing recent recalls
    Given the following Auto Recalls exist:
    |recall_number|manufacturer              |component_description                                   |recalled_days_ago|
    |10155        |TOYOTA, TOYOTA            |FRONT BRAKE PADS, STEERING WHEEL                        |15               |
    |10157        |TOYOTA                    |REAR-VIEW MIRROR                                        |18               |
    |10156        |HONDA, INFINITI, PORSCHE  |BRAKE PAD ASSEMBLY,BRAKE PAD ASSEMBLY,BRAKE PAD ASSEMBLY|25               |
    |10150        |TOYOTA                    |OLD BRAKE PADS                                          |35               |
    And I am on the homepage
    When I fill in "query" with "brake pad recall"
    And I submit the search form
    Then I should be on the search page
    And I should see "FRONT BRAKE PADS, STEERING WHEEL FROM TOYOTA"
    And I should see "BRAKE PAD ASSEMBLY FROM HONDA, INFINITI, PORSCHE"
    And I should not see "REAR-VIEW MIRROR"
    And I should not see "OLD BRAKE PADS"

  Scenario: A search with results containing food recalls
    Given the following Food Recalls exist:
    |recalled_days_ago  | summary                                       | description                                               | url                                                                     |
    |1                  | Stay Puft recalls marshmallows                | These are just too creepy for kids                        | http://www.fda.gov/Safety/Recalls/ucm207251.htm                         |
    |18                 | The Fizz recalls Screw-on Ice Cream Float Cup | The cup is reusable, but not dishwasher safe.             | http://www.fda.gov/Safety/Recalls/ucm207252.htm                         |
    |25                 | Curry recalled due to unlisted allergens      | It contains the ghost curry as well as raw marshmallows   | http://www.fsis.usda.gov/News_&_Events/Recall_061_2009_Release/index.asp|
    |35                 | Old Marshmallow Recall news                   | These were recalled a very long time ago due to staleness | http://www.fsis.usda.gov/News_&_Events/Recall_062_2009_Release/index.asp|
    And I am on the homepage
    When I fill in "query" with "recall of marshmallows"
    And I submit the search form
    Then I should be on the search page
    And I should see "Stay Puft recalls marshmallows"
    And I should see "Curry recalled due to unlisted allergens"
    And I should not see "The Fizz recalls Screw-on Ice Cream Float Cup"
    And I should not see "Old Marshmallow Recall news"

  Scenario: A search with results containing English FAQs
    Given the following FAQs exist:
    | url                   | question                                      | answer        | ranking | locale  |
    | http://localhost:3000 | Who is the president of the United States?    | Barack Obama  | 1       | en      |
    | http://localhost:3000 | Who is the president of the Estados Unidos?   | Barack Obama  | 1       | es      |
    And I am on the homepage
    When I fill in "query" with "president"
    And I submit the search form
    Then I should be on the search page
    And I should see "Who is the president of the United States"
    And I should not see "Who is the president of the Estados Unidos"

  Scenario: A search with results containing English FAQs
    Given the following FAQs exist:
    | url                   | question                                      | answer        | ranking | locale  |
    | http://localhost:3000 | Who is the president of the United States?    | Barack Obama  | 1       | en      |
    | http://localhost:3000 | Who is the president of the Estados Unidos?   | Barack Obama  | 1       | es      |
    And I am on the Spanish homepage
    When I fill in "query" with "president"
    And I submit the search form
    Then I should be on the search page
    And I should not see "Who is the president of the United States"
    And I should see "Who is the president of the Estados Unidos"

  Scenario: Emailing from the home page
    Given I am on the homepage
    When I follow "E-mail us"
    Then I should be on the mobile contact form page
    And I should see "Contact your Government"
    And I should see "Email"
    And I should see "Message"
    When I fill in "Email" with "mobileuser@usa.gov"
    And I fill in "Message" with "I love your site!"
    And I press "Submit"
    Then I should be on the mobile contact form page
    And I should see "Thank you for contacting USA.gov."
    And "musa.gov@mail.fedinfo.gov" should receive an email
    When I open the email
    Then I should see "USA.gov Mobile Inquiry" in the email subject
    And I should see "[FORMGEN]" in the email body

    When I go to the mobile contact form page
    And I follow "USASearch Home"
    Then I should be on the homepage

  Scenario: User does not provide some information for contact form
    Given I am on the mobile contact form page
    And I fill in "Email" with "mobileuser@usa.gov"
    And I press "Submit"
    Then I should see "Missing required fields (*)"
    And the "Email" field should contain "mobileuser@usa.gov"

    When I am on the mobile contact form page
    And I fill in "Message" with "I love your site!"
    And I press "Submit"
    Then I should see "Missing required fields (*)"
    And the "Message" field should contain "I love your site!"

    When I am on the mobile contact form page
    And I fill in "Email" with "bad email"
    And I fill in "Message" with "message"
    And I press "Submit"
    Then I should see "Email address is not valid"
    And the "Email" field should contain "bad email"
    And the "Message" field should contain "message"

  Scenario: Emailing from the Spanish home page
    Given I am on the Spanish homepage
    When I follow "Envíanos un correo electrónico"
    Then I should be on the mobile contact form page
    And I should see "Escríbenos un e-mail"
    And I should see "Tu e-mail"
    And I should see "Mensaje"
    And I fill in "Tu e-mail" with "spanishmobileuser@usa.gov"
    And I fill in "Mensaje" with "I love your site!"
    And I press "Enviar"
    Then I should be on the mobile contact form page
    And I should see "Gracias por contactar a GobiernoUSA.gov. Te responderemos en dos días hábiles."
    And "mgobiernousa.gov@mail.fedinfo.gov" should receive an email
    When I open the email
    Then I should see "GobiernoUSA.gov Mobile Inquiry" in the email subject
    And I should see "[FORMGEN]" in the email body

    When I go to the Spanish mobile contact form page
    Then I should see an image link to "USASearch Home" with url for "http://m.gobiernousa.gov"

  Scenario: Emailing from the Spanish home page with problem
    Given I am on the Spanish homepage
    When I follow "Envíanos un correo electrónico"
    And I fill in "Tu e-mail" with " "
    And I fill in "Mensaje" with " "
    And I press "Enviar"
    Then I should be on the mobile contact form page
    And I should see "Faltan datos requeridos"
    When I fill in "Tu e-mail" with "invalid email"
    And I fill in "Mensaje" with "I love your site"
    And I press "Enviar"
    Then I should be on the mobile contact form page
    And I should see "Este e-mail no es válido"
    And the "Tu e-mail" field should contain "invalid email"
    And the "Mensaje" field should contain "I love your site"

  Scenario: A mobile image search
    Given I am on the homepage
    When I fill in "query" with "social security"
    And I submit the search form
    Then I should be on the search page
    When I follow "Images"
    Then I should be on the image search page
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see 30 image results
    And I should see "Next"

    Given I am on the homepage
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."
    When I follow "Images"
    Then I should be on the image search page
    And I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

    Given I am on the homepage
    When I submit the search form
    Then I should be on the search page
    When I follow "Images"
    Then I should be on the image search page
    And I should see "Please enter search term(s)"