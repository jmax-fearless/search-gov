# frozen_string_literal: true

class SearchgovUrlBulkUploaderJob < ApplicationJob
  queue_as :searchgov

  delegate :upload_and_index, to: :@uploader

  def perform(user, uploader_redis_key)
    @user = user
    @uploader_redis_key = uploader_redis_key

    retrieve_uploader
    upload_and_index
    report_results
  end

  def report_results
    log_results
    send_results_email
  end

  def log_results
    results = @uploader.results
    Rails.logger.info "SearchgovUrlBulkUploaderJob: #{results.name}"
    Rails.logger.info "    #{results.total_count} URLs"
    Rails.logger.info "    #{results.error_count} errors"
  end

  def send_results_email
    results = @uploader.results
    email = BulkUrlUploadResultsMailer.with(user: @user, results: results).results_email
    email.deliver_now
  end

  def retrieve_uploader
    redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
    raw_uploader = redis.get(@uploader_redis_key)
    redis.del(@uploader_redis_key)

    @uploader = Marshal.load(raw_uploader)
  end
end
