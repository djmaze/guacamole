# -*- encoding: utf-8 -*-

Fabricator(:book) do
  title { Faker::Lorem.words.join(' ') }
end
