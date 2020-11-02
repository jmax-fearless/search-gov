# frozen_string_literal: true

class Admin::BulkUrlUploadController < Admin::AdminController
  def index
    @page_title = 'Bulk URL Upload'
  end

  def upload
    begin
      filename= params[:bulk_upload_urls]
      number_of_urls= BulkUrlUploader.new(filename).add_urls
      flash[:success]= "Successfully uploaded file \"#{filename}\" urls."
    rescue StandardError => error
      flash[:error]= error.message
    end
    redirect_to admin_bulk_url_upload_index_path
  end
end
