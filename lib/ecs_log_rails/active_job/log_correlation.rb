module EcsLogRails
  module ActiveJob
    module LogCorrelation
      READER_METHOD = :_ecs_log_rails_apm_log_ids

      def self.included(base)
        base.attr_reader READER_METHOD
        base.around_perform :_ecs_log_rails_capture_apm_ids
      end

      private

      def _ecs_log_rails_capture_apm_ids
        @_ecs_log_rails_apm_log_ids = EcsLogRails.log_correlation_data
        yield
      end
    end
  end
end
