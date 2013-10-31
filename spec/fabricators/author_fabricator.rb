# -*- encoding: utf-8 -*-

Fabricator(:author_with_three_books, from: :author) do
  name 'Star Swirl the Bearded'

  books(count: 3)
end
