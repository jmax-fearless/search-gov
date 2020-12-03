# frozen_string_literal: true

class BulkUrlUploadJobCreator
  def initialize(file, user)
    @file = file
    @user = user
  end

  def create_job!
    SearchgovUrlBulkUploaderJob.perform_later(@user, save_tempfile)
  end

  def save_tempfile
    validate_file
    redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
    redis.set(redis_key, @file.tempfile.read)
    redis_key
  end

  def validate_file
    BulkUrlUploader::Validator.new(@file).validate!
  end

  def redis_key
    @redis_key ||= "bulk_url_upload:#{@file.original_filename}:#{SecureRandom.uuid}"
  end
end
