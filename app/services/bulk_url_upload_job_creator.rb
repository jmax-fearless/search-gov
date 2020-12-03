# frozen_string_literal: true

class BulkUrlUploadJobCreator
  def initialize(file, user)
    @file = file
    @user = user
  end

  def create_job!
    validate_file
    create_uploader
    save_uploader
    SearchgovUrlBulkUploaderJob.perform_later(@user, redis_key)
  end

  def redis_key
    @redis_key ||= "bulk_url_upload:#{@file.original_filename}:#{SecureRandom.uuid}"
  end

  private

  def validate_file
    BulkUrlUploader::Validator.new(@file).validate!
  end

  def create_uploader
    urls = @file.tempfile.readlines
    filename= @file.original_filename
    @uploader = BulkUrlUploader.new(filename, urls)
  end

  def save_uploader
    redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
    redis.set(redis_key, Marshal.dump(@uploader))
  end
end
