ENV["RAILS_ENV"] = "benchmark"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'rails/performance_test_help'

class ActionDispatch::PerformanceTest
  self.profile_options = { runs: 1, metrics: [:wall_time, :gc_runs, :gc_time] }
end
