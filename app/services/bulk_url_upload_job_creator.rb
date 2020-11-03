# frozen_string_literal: true

class BulkUrlUploadJobCreator
  def initialize(file)
    @file = file
  end

  def unique_file_name
    time_string = Time.now.utc.strftime('%Y%m%d%H%M%S')
    pid_string = Process.pid.to_s
    base_filename = @file.original_filename
    "#{Dir.tmpdir}/bulk-url-upload-#{time_string}-#{pid_string}-#{base_filename}"
  end

  # Rails doesn't guarantee that our TempFile, in @file, will live
  # longer than our request. Since we need it to still be there when
  # the ActiveJob kicks off, we create a new link to it. It is the
  # ActiveJob's responsibility to delete the new link after it's done.
  def save_tempfile
    saved_file_name = unique_file_name
    File.link(@file.tempfile.path, saved_file_name)
    saved_file_name
  end

  def create_job!
    raise 'Please choose a file to upload' unless @file

    SearchgovUrlBulkUploaderJob.perform_later(save_tempfile)
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
