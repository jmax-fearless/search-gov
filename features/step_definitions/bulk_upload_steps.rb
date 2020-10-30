# frozen_string_literal: true

Then /^there should not be a bulk upload job$/ do
  the_adapter = ActiveJob::Base.queue_adapter
  enqueued_jobs = the_adapter.enqueued_jobs

  expect(enqueued_jobs).to be_empty
end

Then /^there should be a bulk upload job$/ do
  the_adapter = ActiveJob::Base.queue_adapter
  enqueued_jobs = the_adapter.enqueued_jobs

  expect(enqueued_jobs[0]).to be_a(SearchgovUrlBulkUploaderJob)
end
