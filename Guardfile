# -*- encoding : utf-8 -*-
guard 'bundler' do
  watch(/^.+\.gemspec/)
end

guard 'rspec', spec_paths: 'spec/unit' do
  watch('spec/.+\.rb')
  watch(%r{lib/ashikawa-core/(.+)\.rb$}) { |m| "spec/unit/#{m[1]}_spec.rb" }
end
