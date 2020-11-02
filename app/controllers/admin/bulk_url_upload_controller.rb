# frozen_string_literal: true

class Admin::BulkUrlUploadController < Admin::AdminController
  def index
    @page_title = 'Bulk URL Upload'
  end

  def upload
    begin
      file= params[:bulk_upload_urls]
      BulkUrlUploader.new(file).create_job!
      flash[:success]= "Successfully uploaded #{file.original_filename}."
    rescue StandardError => error
      flash[:error]= error.message
    end
    redirect_to admin_bulk_url_upload_index_path
  end
end
