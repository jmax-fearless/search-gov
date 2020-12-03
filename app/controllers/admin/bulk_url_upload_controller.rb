# frozen_string_literal: true

module Admin
  class BulkUrlUploadController < AdminController
    def index
      @page_title = 'Bulk URL Upload'
    end

    def upload
      begin
        file = params[:bulk_upload_urls]
        job_creator = BulkUrlUploadJobCreator.new(file, current_user)
        job_creator.create_job!
        flash[:success] = success_message(file.original_filename)
      rescue BulkUrlUploader::Error => e
        flash[:error] = e.message
      end

      redirect_to admin_bulk_url_upload_index_path
    end

    def success_message(filename)
      <<~SUCCESS_MESSAGE
        Successfully uploaded #{filename} for processing.
        The results will be emailed to you.
      SUCCESS_MESSAGE
    end
  end
end
