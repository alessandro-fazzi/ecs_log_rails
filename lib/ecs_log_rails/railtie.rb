require "rails/railtie"
require "ecs_log_rails/ordered_options"

module EcsLogRails
  class Railtie < Rails::Railtie
    config.ecs_log_rails = EcsLogRails::OrderedOptions.new
    config.ecs_log_rails.enabled = false
    config.ecs_log_rails.keep_original_rails_log = true
    config.ecs_log_rails.log_level = :info
    config.ecs_log_rails.log_file = File.join("log", "ecs_log_rails.log")
    config.ecs_log_rails.service_env = Rails.env
    config.ecs_log_rails.service_type = "rails"
    config.ecs_log_rails.log_correlation = false

    config.after_initialize do |app|
      app.config.ecs_log_rails.service_name ||= Rails.application.class.module_parent.name
      app.config.lograge.enabled = app.config.ecs_log_rails.enabled

      if app.config.ecs_log_rails.enabled
        EcsLogRails.setup(app)

        if app.config.ecs_log_rails.log_correlation && defined?(LogrageActivejob)
          if app.config.lograge_activejob.custom_options
            raise "EcsLogRails: lograge_activejob.custom_options is already configured. " \
                  "Remove it from your initializer to use log_correlation."
          end

          reader = EcsLogRails::ActiveJob::LogCorrelation::READER_METHOD
          app.config.lograge_activejob.custom_options = ->(event) do
            job = event.payload[:job]
            return {} unless job.respond_to?(reader)

            job.public_send(reader) || {}
          end
        end
      end
    end
  end
end
