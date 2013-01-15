Feature: Boosted Content
  In order to boost specific pages to the top of search results
  As an affiliate
  I want to manage boosted Content

  Scenario: Visiting Boosted Contents index page
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                                                                                                      | url                               | description          | status   | publish_start_on | publish_end_on |
      | Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis at tincidunt erat. Sed sit amet massa massa. | http://www.hello.gov/there.htm    | fire island          | active   | 08/30/2011       | 08/30/2012     |
      | fresnel lens                                                                                               | http://www.hello.gov/fresnels.htm | fresnels description | inactive | 09/01/2011       |                |
    And the following Boosted Content Keywords exist for the entry titled "fresnel lens"
      | value |
      | abc   |
      | xyz   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see the browser page titled "Best Bets: Text"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Best Bets: Text
    And I should see "Best Bets: Text" in the page header
    And I should see "Displaying all 2 Best Bets: Text entries"
    And I should see 2 Boosted Content Entries
    And I should see "Add new text"
    And I should see the following table rows:
      | Title                          | URL                        | Publish Start | Status   |
      | fresnel lens                   | www.hello.gov/fresnels.htm | 9/1/2011      | Inactive |
      | Lorem ipsum dolor sit amet,... | www.hello.gov/there.htm    | 8/30/2011     | Active   |
    When I follow "fresnel lens"
    Then I should see "fresnel lens"
    And I should see "http://www.hello.gov/fresnels.htm"
    And I should see "fresnels description"
    And I should see "Inactive"
    And I should see "xyz"
    And I should see "abc"

    When there are 30 Boosted Content entries exist for the affiliate "aff.gov":
      | locale | status |
      | en     | active |
    And I go to the aff.gov's boosted contents page
    And I should see "Displaying Best Bets: Text entries 1 - 20 of 32 in total"
    And I should see 20 Boosted Content Entries
    When I follow "Next"
    Then I should see "Displaying Best Bets: Text entries 21 - 32 of 32 in total"
    And I should see "title 10"

  Scenario: Create a new Boosted Content entry
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "aff site has no Best Bets: Text"
    When I follow "Add new text"
    Then I should see the browser page titled "Add a new Best Bets: Text"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Add a new Best Bets: Text
    And I should see "Add a new Best Bets: Text" in the page header
    And the "Publish start date" field should contain today's date

    When I fill in the following:
      | Title*                | Test                |
      | URL                   | http://www.test.gov |
      | Publish start date    | 07/01/2011          |
      | Publish end date      | 07/01/2016          |
      | Keyword 0             | unrelated           |
      | Description           | Test Description    |

    And I fill in "Title" with "Test"
    And I fill in "URL" with "http://www.test.gov"
    And I fill in "Description" with "Test Description"
    And I fill in "Keyword" with "unrelated, terms"
    And I select "Active" from "Status*"
    And I press "Add"
    Then I should see "Best Bets: Text entry successfully added"
    And I should see the browser page titled "Best Bets: Text"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Best Bets: Text
    And I should see "Best Bets: Text" in the page header
    And I should see "Test"
    And I should see "http://www.test.gov"
    And I should see "Test Description"
    And I should see "Active"
    And I should see boosted content keyword "unrelated"

    When I follow "Add another Best Bets: Text"
    Then I should see the browser page titled "Add a new Best Bets: Text"
    When I follow "Cancel"
    Then I should see "Best Bets: Text" in the page header

  Scenario: Create Boosted Content with URL without http:// prefix
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Add new text"
    And I fill in "Title" with "Test"
    And I fill in "URL" with "www.test.gov"
    And I fill in "Description" with "Test Description"
    And I select "Active" from "Status*"
    And I press "Add"
    Then I should see "Best Bets: Text entry successfully added"
    And I should see "http://www.test.gov"

  Scenario: Validating Affiliate Boosted Content on create
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title        | url                            | description | status |
      | fresnel lens | http://www.hello.gov/there.htm | fire island | active |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Add new text"
    And I fill in the following:
      | Publish start date | 07/01/2012                              |
      | Publish end date   | 07/01/2011                              |
    And I press "Add"
    Then I should see "Title can't be blank"
    And I should see "URL can't be blank"
    And I should see "Description can't be blank"
    And I should see "Status must be selected"
    And I should see "Publish end date can't be before publish start date"

    When I fill in "URL" with "http://www.hello.gov/there.htm"
    And I fill in "Publish start date" with ""
    And I press "Add"
    Then I should see "URL has already been boosted"
    And I should see "Publish start date can't be blank"

  Scenario: Edit a Boosted Content entry
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
     | title            | url               | description       |
     | a title          | http://a.url.gov  | A description     |
    And the following Boosted Content Keywords exist for the entry titled "a title"
      | value |
      | abc   |
      | xyz   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Edit"
    Then I should be on the edit affiliate boosted content page for "aff.gov"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff site > Edit Best Bets: Text Entry
    And I fill in "Title" with "new title"
    And I fill in "Description" with "new description"
    And I fill in "Keyword 0" with "banana"
    And I fill in "Keyword 1" with ""
    And I press "Update"
    Then I should see "Best Bets: Text entry successfully updated"
    And I should see "new title"
    And I should not see "a title"
    And I should see "http://a.url.gov"
    And I should see "new description"
    And I should not see "a description"
    And I should see boosted content keyword "banana"
    And I should not see "xyz"
    When I follow "Edit"
    And I follow "Cancel"
    Then I should see "Best Bets: Text" in the page header

  Scenario: Edit a Boosted Content's URL without http:// prefix
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
     | title            | url               | description       |
     | a title          | http://a.url.gov  | A description     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Edit"
    Then the "URL" field should contain "http://a.url.gov"
    When I fill in "URL" with "b.url.gov"
    And I press "Update"
    Then I should see "Best Bets: Text entry successfully updated"
    And I should see "http://b.url.gov"

  Scenario: Validating Affiliate Boosted Content on update
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
     | title            | url               | description       |
     | a title          | http://a.url.gov  | A description     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Edit"
    And I fill in "Title" with ""
    And I fill in "URL" with ""
    And I fill in "Description" with ""
    And I fill in "Publish start date" with ""
    And I select "Select a status" from "Status*"
    When I press "Update"
    Then I should see "Title can't be blank"
    And I should see "URL can't be blank"
    And I should see "Description can't be blank"
    And I should see "Status must be selected"
    And I should see "Publish start date can't be blank"

  Scenario: Deleting a boosted content
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title          | url                | description   |
      | a title        | http://a.url.gov/1 | A description |
      | another title  | http://a.url.gov/2 | A description |
      | one more title | http://a.url.gov/3 | A description |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "Displaying all 3 Best Bets: Text entries"
    And I should see "a title"
    And I should see "another title"
    And I should see "one more title"
    When I press "Delete" on the 2nd boosted content entry
    Then I should see "Best Bets: Text entry successfully deleted"
    And I should see "Displaying all 2 Best Bets: Text entries"
    And I should see "a title"
    And I should see "one more title"

  Scenario: Deleting all boosted contents
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         |aff.gov           | aff@bar.gov             | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title          | url                | description   |
      | a title        | http://a.url.gov/1 | A description |
      | another title  | http://a.url.gov/2 | A description |
      | one more title | http://a.url.gov/3 | A description |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "a title"
    And I should see "another title"
    And I should see "one more title"
    When I press "Delete all"
    Then I should see "All Best Bets: Text entries successfully deleted"
    And I should see "aff site has no Best Bets: Text entry"
    And I should not see "Delete all" button

  Scenario: Site visitor sees relevant boosted results for given affiliate search
    Given the following Affiliates exist:
      | display_name     | name                  | contact_email         | contact_name        |
      | aff site         | aff.gov               | aff@bar.gov           | John Bar            |
      | bar site         | bar.gov               | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title              | url                                               | description                          |
      | Our Emergency Page | http://www.aff.gov/mysuperduperawesomelongurl/911 | Updated information on the emergency |
      | FAQ Emergency Page | http://www.aff.gov/mysuperduperawesomelongurl/faq | More information on the emergency    |
      | Our Tourism Page   | http://www.aff.gov/mysuperduperawesomelongurl/tou | Tourism information                  |
    And the following Boosted Content Keywords exist for the entry titled "Our Emergency Page"
      | value       |
      | unrelated   |
      | terms       |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title              | url                    | description                        |
      | Bar Emergency Page | http://www.bar.gov/911 | This should not show up in results |
      | Pelosi misspelling | http://www.bar.gov/pel | Synonyms file test works           |
      | all about agencies | http://www.bar.gov/pe2 | Stemming works                     |
    When I go to aff.gov's search page
    And I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "Recommended by aff site"
    And I should see "Our Emergency Page" in the boosted contents section
    And I should see "www.aff.gov/.../911" in the boosted contents section
    And I should see "Updated information on the emergency" in the boosted contents section
    And I should see "FAQ Emergency Page" in the boosted contents section
    And I should see "www.aff.gov/.../faq" in the boosted contents section
    And I should see "More information on the emergency" in the boosted contents section
    And I should not see "Our Tourism Page" in the boosted contents section
    And I should not see "Bar Emergency Page" in the boosted contents section

    When I go to bar.gov's search page
    And I fill in "query" with "Peloci"
    And I submit the search form
    Then I should see "Synonyms file test works" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "agency"
    And I submit the search form
    Then I should see "Stemming works" within "#boosted"

    When I go to aff.gov's search page
    And I fill in "query" with "unrelated"
    And I submit the search form
    Then I should see "Our Emergency Page" within "#boosted"

  Scenario: Site visitor sees highlighted terms
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale  |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | en      |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | es      |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                           | url                    | description                          |
      | Emergency Information           | http://www.aff.gov/911 | Updated information on the emergency |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title                             | url                    | description                        |
      | la página de prueba de Emergencia | http://www.bar.gov/911 | Some terms                         |
    When I go to aff.gov's search page
    And I fill in "query" with "information"
    And I press "Search"
    Then I should see "Information" in bold font

    When I go to bar.gov's search page
    And I fill in "query" with "pagina"
    And I press "Buscar"
    Then I should see "página" in bold font

  Scenario: Spanish site visitor sees relevant boosted results for given affiliate search
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | es     |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | es     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                                  | url                    | description                          |
      | Nuestra página de Emergencia           | http://www.aff.gov/911 | Updated information on the emergency |
      | Preguntas frecuentes emergencia página | http://www.aff.gov/faq | More information on the emergency    |
      | Our Tourism Page                       | http://www.aff.gov/tou | Tourism information                  |
    And the following Boosted Content Keywords exist for the entry titled "Nuestra página de Emergencia"
      | value       |
      | unrelated   |
      | terms       |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title                             | url                    | description                        |
      | la página de prueba de Emergencia | http://www.bar.gov/911 | This should not show up in results |
      | Pelosi falta de ortografía        | http://www.bar.gov/pel | Synonyms file test works           |
    When I go to aff.gov's search page
    And I fill in "query" with "emergencia"
    And I press "Buscar"
    Then I should see "Recomendación de aff site"
    And I should see "Nuestra página de Emergencia" within "#boosted"
    And I should see "Preguntas frecuentes emergencia página" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"
    And I should not see "la página de prueba de Emergencia" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "Peloci"
    And I press "Buscar"
    Then I should see "Synonyms file test works" within "#boosted"

    When I go to aff.gov's search page
    And I fill in "query" with "unrelated"
    And I press "Buscar"
    Then I should see "Nuestra página de Emergencia" within "#boosted"

  Scenario: Searching for a Spanish word without diacritics
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title              | url                                                            | description                               |
      | Día de los Muertos | http://www.latino.si.edu/education/LVMDayoftheDeadFestival.htm | The Smithsonian Latino Center presents... |
    When I go to aff.gov's search page
    And I fill in "query" with "dia"
    And I press "Search"
    Then I should see "Día de los Muertos"
    And I should see "The Smithsonian Latino Center presents"

    When I go to aff.gov's search page
    And I fill in "query" with "Día"
    And I press "Search"
    Then I should see "Día de los Muertos"
    And I should see "The Smithsonian Latino Center presents"

  Scenario: Uploading valid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff <i>site</i>  | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Bulk upload"
    Then I should see the browser page titled "Bulk Upload Best Bets: Text"
    And I should see the following breadcrumbs: USASearch > Admin Center > aff <i>site</i> > Bulk Upload Best Bets: Text
    And I should see "Bulk Upload Best Bets: Text" in the page header
    And I attach the file "features/support/boosted_content.xml" to "bulk_upload_file"
    And I press "Upload"
    Then I should see "Successful Bulk Import for affiliate 'aff <i>site</i>'"
    Then I should see "2 Best Bets: Text entries successfully created."

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"

    When I follow "Bulk upload"
    And I attach the file "features/support/new_boosted_content.xml" to "bulk_upload_file"
    And I press "Upload"
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "New results about Texas"
    And I should see "New results about hurricanes"

  Scenario: Uploading invalid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         |aff.gov           | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Bulk upload"
    And I attach the file "features/support/missing_title_boosted_content.xml" to "bulk_upload_file"
    And I press "Upload"
    Then I should see "Your XML document could not be processed. Please check the format and try again."

    When I go to aff.gov's search page
    And I fill in "query" with "tourism"
    And I submit the search form
    Then I should see "Our Tourism Page" within "#boosted"

  Scenario: Uploading valid boosted CSV document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name    | name    | contact_email | contact_name |
      | aff <i>site</i> | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Bulk upload"
    And I attach the file "features/support/boosted_content.csv" to "bulk_upload_file"
    And I press "Upload"
    Then I should see "Successful Bulk Import for affiliate 'aff <i>site</i>'"
    Then I should see "2 Best Bets: Text entries successfully created."

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"

    When I follow "Bulk upload"
    And I attach the file "features/support/new_boosted_content.csv" to "bulk_upload_file"
    And I press "Upload"
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    Then I should see "New results about Texas"
    And I should see "New results about hurricanes"

  Scenario: Uploading invalid booster CSV document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         |aff.gov           | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Bulk upload"
    And I attach the file "features/support/missing_title_boosted_content.csv" to "bulk_upload_file"
    And I press "Upload"
    Then I should see "Your CSV document could not be processed. Please check the format and try again."

    When I go to aff.gov's search page
    And I fill in "query" with "tourism"
    And I submit the search form
    Then I should see "Our Tourism Page" within "#boosted"

   Scenario: Uploading unsupported boosted content document as a logged in affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         |aff.gov           | aff@bar.gov           | John Bar            |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Best bets"
    And I follow "View all" in the affiliate boosted contents section
    And I follow "Bulk upload"
    And I attach the file "features/support/cant_read_this.doc" to "bulk_upload_file"
    And I press "Upload"
    Then I should see "Your filename should have .xml, .csv or .txt extension"

  Scenario: Affiliate search user should see only active boosted contents within publish date range
    Given the following Affiliates exist:
      | display_name | name    | contact_email              | contact_name |
      | aff site     | aff.gov | affiliate_manager@site.gov | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                                | url                         | description                      | status   | publish_start_on | publish_end_on |
      | expired boosted content              | http://www.aff.gov/expired  | expired description              | active   | prev_month       | yesterday      |
      | future1 boosted content              | http://www.aff.gov/future1  | future1 description              | active   | tomorrow         | next_month     |
      | future2 boosted content              | http://www.aff.gov/future2  | future2 description              | active   | tomorrow         |                |
      | current boosted content              | http://www.aff.gov/current  | current description              | active   | today            | next_month     |
      | current but inactive boosted content | http://www.aff.gov/inactive | current but inactive description | inactive | today            |                |
    When I go to aff.gov's search page
    And I fill in "query" with "boosted"
    And I press "Search"
    Then I should see "current boosted content"
    And I should not see "current but inactive"
    When I fill in "query" with "expired"
    And I press "Search"
    Then I should not see "expired boosted content"
    When I fill in "query" with "future1"
    And I press "Search"
    Then I should not see "future1 boosted content"
    When I fill in "query" with "future2"
    And I press "Search"
    Then I should not see "future2 boosted content"

  Scenario: Affiliate search user should see boosted contents with higher relevancy on title
    Given the following Affiliates exist:
      | display_name | name    | contact_email              | contact_name |
      | aff site     | aff.gov | affiliate_manager@site.gov | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title                     | url                         | description           | status | publish_start_on |
      | boosted content 1         | http://www.aff.gov/current1 | current description 1 | active | today            |
      | boosted content 2         | http://www.aff.gov/current2 | current description 2 | active | today            |
      | current boosted content 3 | http://www.aff.gov/current3 | description 3         | active | today            |
      | current boosted content 4 | http://www.aff.gov/current4 | description 4         | active | today            |
      | current boosted content 5 | http://www.aff.gov/current5 | description 5         | active | today            |
    When I go to aff.gov's search page
    And I fill in "query" with "current"
    And I press "Search"
    Then I should see "current boosted content 3" in the boosted contents section
    And I should see "current boosted content 4" in the boosted contents section
    And I should see "current boosted content 5" in the boosted contents section
    And I should not see "boosted content 1" in the boosted contents section
    And I should not see "boosted content 2" in the boosted contents section

  Scenario: Affiliate search user should see boosted contents with medium relevancy on description
    Given the following Affiliates exist:
      | display_name | name    | contact_email              | contact_name |
      | aff site     | aff.gov | affiliate_manager@site.gov | John Bar     |
    And the following Boosted Content entries exist for the affiliate "aff.gov"
      | title             | url                         | description           | status | publish_start_on |
      | boosted content 1 | http://www.aff.gov/current1 | description 1         | active | today            |
      | boosted content 2 | http://www.aff.gov/current2 | description 2         | active | today            |
      | boosted content 3 | http://www.aff.gov/current3 | current description 3 | active | today            |
      | boosted content 4 | http://www.aff.gov/current4 | current description 4 | active | today            |
      | boosted content 5 | http://www.aff.gov/current5 | current description 5 | active | today            |
    When I go to aff.gov's search page
    And I fill in "query" with "current"
    And I press "Search"
    Then I should see "boosted content 3" in the boosted contents section
    And I should see "boosted content 4" in the boosted contents section
    And I should see "boosted content 5" in the boosted contents section
    And I should not see "boosted content 1" in the boosted contents section
    And I should not see "boosted content 2" in the boosted contents section