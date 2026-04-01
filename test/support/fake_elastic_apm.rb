class FakeElasticAPM
  def initialize
    @enabled = true
  end

  def enable! = @enabled = true
  def disable! = @enabled = false

  def log_ids(&block)
    data = if @enabled
      {
        transaction_id: "abc123",
        span_id: nil,
        trace_id: "trace456",
      }
    else
      {}
    end

    block.call(*data.values)
  end
end
