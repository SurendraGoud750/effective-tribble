class Request < ApplicationRecord
  enum status: {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3,
    cancelled: 4
  }

  validates :idempotency_key, presence: true, uniqueness: true
end