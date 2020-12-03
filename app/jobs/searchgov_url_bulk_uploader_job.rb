# frozen_string_literal: true

class SearchgovUrlBulkUploaderJob < ApplicationJob
  queue_as :searchgov

  def perform(user, urls_redis_key)
    @user = user
    @urls_redis_key = urls_redis_key

    uploader.upload_and_index
    report_results
  end

  def report_results
    log_results
    send_results_email
  end

  def log_results
    results = uploader.results
    Rails.logger.info "SearchgovUrlBulkUploaderJob: #{results.name}"
    Rails.logger.info "    #{results.total_count} URLs"
    Rails.logger.info "    #{results.error_count} errors"
  end

  def send_results_email
    results = uploader.results
    email = BulkUrlUploadResultsMailer.with(user: @user, results: results).results_email
    email.deliver_now
  end

  def uploader
    @uploader ||= BulkUrlUploader.new(friendly_name, urls)
  end

  def urls
    return @urls if @urls

    redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
    raw_urls = redis.get(@urls_redis_key)
    redis.del(@urls_redis_key)

    @urls = Marshal.load(raw_urls)
  end

  def friendly_name
    @urls_redis_key.split(':')[1]
  end
end
