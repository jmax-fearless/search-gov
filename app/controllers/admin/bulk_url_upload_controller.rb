# frozen_string_literal: true

class Admin::BulkUrlUploadController < Admin::AdminController
  def index
    @page_title = 'Bulk URL Upload'
  end

  def upload
    begin
      number_of_urls= BulkUrlUploader.new(params[:bulk_upload_urls]).add_urls
      flash[:success]= "Successfully uploaded #{number_of_urls} urls."
    rescue StandardError => error
      flash[:error]= error.message
    end
    redirect_to admin_bulk_url_upload_index_path
  end
end
