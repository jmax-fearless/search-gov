# frozen_string_literal: true

describe 'Bulk URL upload' do
  subject(:bulk_upload) do
    visit url
    attach_file('bulk_upload_urls', url_file)
    click_button('Upload')
  end

  let(:url) { '/admin/bulk_url_upload' }
  let(:url_filename) { 'good_url_file.txt' }
  let(:url_file) { file_fixture("txt/#{url_filename}") }

  it_behaves_like 'a page restricted to super admins'

  describe 'bulk uploading a file of URLs' do
    include_context 'log in super admin'

    it 'queues a bulk url upload job' do
      expect { bulk_upload }.to have_enqueued_job(SearchgovUrlBulkUploaderJob).
        with(instance_of(User), instance_of(String))
    end

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows a confirmation message' do
      bulk_upload
      expect(page).to have_text(
        <<~CONFIRMATION_MESSAGE
          Successfully uploaded #{url_filename} for processing.
          The results will be emailed to you.
        CONFIRMATION_MESSAGE
      )
    end
  end

  describe 'trying to bulk upload a file of URLs when there is no file attached' do
    include_context 'log in super admin'

    subject(:bulk_upload) do
      visit url
      click_button('Upload')
    end

    it 'does not queue a bulk url upload job' do
      expect { bulk_upload }.not_to have_enqueued_job(SearchgovUrlBulkUploaderJob)
    end

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows an error message' do
      bulk_upload
      expect(page).to have_text(
        <<~ERROR_MESSAGE
          Please choose a file to upload.
        ERROR_MESSAGE
      )
    end
  end

  describe 'trying to bulk upload a file of URLs that is not a text file' do
    include_context 'log in super admin'

    let(:url_file) { file_fixture('word/bogus_url_file.docx') }

    it 'does not queue a bulk url upload job' do
      expect { bulk_upload }.not_to have_enqueued_job(SearchgovUrlBulkUploaderJob)
    end

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows an error message' do
      bulk_upload
      expect(page).to have_text(
        <<~ERROR_MESSAGE
          Files of type application/vnd.openxmlformats-officedocument.wordprocessingml.document are not supported
        ERROR_MESSAGE
      )
    end
  end

  describe 'trying to bulk upload a file of URLs that is too big' do
    include_context 'log in super admin'

    let(:url_filename) { 'too_big_url_file.txt' }

    it 'does not queue a bulk url upload job' do
      expect { bulk_upload }.not_to have_enqueued_job(SearchgovUrlBulkUploaderJob)
    end

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows an error message' do
      bulk_upload
      expect(page).to have_text(
        <<~ERROR_MESSAGE
          #{url_filename} is too big; please split it.
        ERROR_MESSAGE
      )
    end
  end
end
