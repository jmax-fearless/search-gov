Feature: Admin Interface
  In order to give affiliates the ability to submit a file of URLs for indexing by Garfield
  As an admin
  I want to upload a file containing URLs

  Scenario: Bulk-uploading URLs for on-demand indexing as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the bulk url upload admin page
    Then I should see "Bulk URL Upload"

    When I attach the file "features/support/bulk_upload_urls.txt" to "bulk_upload_urls"
    And I press "Upload"
    Then I should be on the bulk url upload admin page
    And I should see "Successfully uploaded file \"bulk_upload_urls.txt\"."
    And there should be a bulk upload job

    When I attach the file "features/support/does_not_exist.txt" to "bulk_upload_urls"
    And I press "Upload"
    Then I should be on the bulk url upload admin page
    And I should see "Could not find file \"does_not_exist.txt\"."
    And there should not be a bulk upload job

    When I do not attach a file to "bulk_upload_urls"
    And I press "Upload"
    Then I should be on the bulk url upload admin page
    And I should see "Please choose a file to upload"
    And there should not be a bulk upload job
