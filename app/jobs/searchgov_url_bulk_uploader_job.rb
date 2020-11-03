# frozen_string_literal: true

class SearchgovUrlBulkUploaderJob < ApplicationJob
  queue_as :searchgov

  def perform
    Rails.logger.info 'SearchgovUrlBulkUploaderJob#perform: got here'
  end
end
