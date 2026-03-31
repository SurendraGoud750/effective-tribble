class ProcessRequestJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  def perform(request_id)
    request = Request.find(request_id)

    return if request.completed? || request.cancelled?

    request.with_lock do
      return if request.processing?
      request.update!(status: :processing)
    end

    RequestProcessor.new(request).call

    request.update!(status: :completed)

  rescue ExternalServiceError => e
    request.update!(status: :failed, error_message: e.message)
    raise e
  end
end