# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:cop) do |cop_task|
  cop_task.patterns = ['lib/**/*.rb']
  cop_task.formatters = ['files']
  cop_task.fail_on_error = true
end
task spec: :cop
task default: :spec
