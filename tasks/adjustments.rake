# -*- encoding : utf-8 -*-
## Specs
# Difference to Devtools:
# * Acceptance, no integration tests

Rake::Task['spec'].clear
Rake::Task['spec:integration'].clear

desc 'Run all specs'
task spec: %w[ spec:unit spec:acceptance ]

namespace :spec do
  desc 'Run the acceptance tests. Requires ArangoDB to be running.'
  RSpec::Core::RakeTask.new(:acceptance) do |spec|
    spec.pattern = 'spec/acceptance/*_spec.rb'
  end
end

## CI Task
# Differences to Devtools:
# * Only run specific tasks

Rake::Task['ci'].clear

desc 'Run all metrics and specs'
task ci: %w[
  spec
  metrics:coverage
  metrics:reek
  metrics:rubocop
  metrics:yardstick:verify
]

## Default Task
task default: :ci
