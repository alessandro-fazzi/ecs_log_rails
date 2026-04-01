require "minitest/autorun"
require "minitest/mock"
require "logger"
require "active_job"
require "ecs_log_rails"

ActiveJob::Base.logger = Logger.new(IO::NULL)

# Simulate gem presence in test env
module ElasticAPM
  module_function def log_ids = {}
end

Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }
