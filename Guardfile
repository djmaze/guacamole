# -*- encoding : utf-8 -*-
guard 'bundler' do
  watch(/^.+\.gemspec/)
end

guard 'rspec', spec_paths: 'spec/unit' do
  watch(%r{spec/.+\.rb})
  watch(%r{lib/guacamole/(.+)\.rb$}) { |m| "spec/unit/#{m[1]}_spec.rb" }
end

guard 'yard', port: '8808' do
  watch(%r{lib/.+\.rb})
end
