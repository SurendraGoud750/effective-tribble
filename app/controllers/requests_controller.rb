class RequestsController < ApplicationController
  def create
    request = Request.find_by(idempotency_key: params[:idempotency_key])

    if request
      return render json: request, status: :ok
    end

    request = Request.create!(
      idempotency_key: params[:idempotency_key],
      payload: params[:payload],
      status: :pending
    )

    ProcessRequestJob.perform_later(request.id)

    render json: request, status: :accepted

  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def cancel
    request = Request.find(params[:id])

    if request.processing?
      return render json: { error: "Already processing" }, status: 409
    end

    request.update!(status: :cancelled)
    render json: request
  end
end