require "test_helper"

ActiveJob::Base.queue_adapter = :test

module ActiveJob
  class LogCorrelationTest < Minitest::Test
    include ElasticAPMTestHelper

    def setup
      super
      @apm_data = {apm_transaction_id: "abc123", apm_trace_id: "trace456"}
    end

    def test_reader_populated
      job = Class.new(ActiveJob::Base) do
        include EcsLogRails::ActiveJob::LogCorrelation

        def perform = nil
      end.new

      with_apm_transaction { job.perform_now }

      assert_equal @apm_data, job._ecs_log_rails_apm_log_ids
    end

    def test_reader_populated_even_when_perform_raises
      job = Class.new(ActiveJob::Base) do
        include EcsLogRails::ActiveJob::LogCorrelation

        def perform = raise StandardError
      end.new

      with_apm_transaction do
        assert_raises(StandardError) { job.perform_now }
      end

      assert_equal @apm_data, job._ecs_log_rails_apm_log_ids
    end

    class CallbacksOrderTest < self
      def test_including_log_correlation_module_before_a_transaction_is_open_will_fail
        job = Class.new(ActiveJob::Base) do
          include ElasticAPMTestHelper
          include EcsLogRails::ActiveJob::LogCorrelation

          around_perform do |job, block|
            with_apm_transaction { block.call }
          end

          def perform = nil
        end.new

        job.perform_now

        # Empty data because we captured it before the transaction was open
        assert_equal({}, job._ecs_log_rails_apm_log_ids)
      end

      def test_including_log_correlation_module_after_a_transaction_is_open_will_work
        job = Class.new(ActiveJob::Base) do
          include ElasticAPMTestHelper

          around_perform do |job, block|
            with_apm_transaction { block.call }
          end
          include EcsLogRails::ActiveJob::LogCorrelation

          def perform = nil
        end.new

        job.perform_now

        assert_equal(@apm_data, job._ecs_log_rails_apm_log_ids)
      end
    end
  end
end
