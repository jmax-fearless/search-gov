# frozen_string_literal: true

class BulkUrlUploader
  MAXIMUM_NUMBER_OF_URLS_PER_FILE= 15000

  def initialize(file)
    @file= file
  end

  def create_job!
    raise 'Please choose a file to upload' unless @file

    SearchgovUrlBulkUploaderJob.perform_later('ferd')
  end
end

# Junk from Superfresh bulk uploader for reference and theft. Delete
# before release.

  # VALID_CONTENT_TYPES = %w{text/plain txt}

  # def valid_upload_file?(file)
  #   file.present? and VALID_CONTENT_TYPES.include?(file.content_type)
  # end

  #   file = params[:bulk_upload_urls]
  #   unless valid_upload_file?(file)
  #     flash[:error]= "Invalid file format; please upload a plain text file (.txt)."
  #   else
  #     begin
  #       uploaded_count = SuperfreshUrl.process_file(file, nil, 65535)
  #       if uploaded_count > 0
  #         flash[:success] = "Successfully uploaded #{uploaded_count} urls."
  #       else
  #         flash[:error] = "No urls uploaded; please check your file and try again."
  #       end
  #     rescue StandardError => error
  #       flash[:error] = error.message
  #     end
  #   end
  #   redirect_to admin_bulk_url_upload_index_path
  # end
