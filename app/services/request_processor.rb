class RequestProcessor
  def initialize(request)
    @request = request
  end

  def call
    simulate_external_call
  end

  private

  def simulate_external_call
    sleep(2) # simulate delay

    # 30% failure simulation
    raise ExternalServiceError, "Downstream failure" if rand < 0.3
  end
end