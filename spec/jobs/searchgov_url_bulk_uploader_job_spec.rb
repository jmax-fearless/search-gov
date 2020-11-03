require 'spec_helper'

describe SearchgovUrlBulkUploaderJob do
  describe '#perform' do
    it 'queues a job' do
      ActiveJob::Base.queue_adapter= :test
      fake_uploaded_file= ActionDispatch::Http::UploadedFile.new(
        {
          tempfile: Tempfile.new,
          filename: 'original_filename.txt'
        })
      expect { BulkUrlUploadJobCreator.new(fake_uploaded_file).create_job! }.
        to have_enqueued_job
    end
  end
end
