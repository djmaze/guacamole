# -*- encoding : utf-8 -*-
require 'guacamole'
require 'acceptance/spec_helper'

require 'fabricators/book'
require 'fabricators/author'

class AuthorsCollection
  include Guacamole::Collection

  map do
    referenced_by :books
  end
end

class BooksCollection
  include Guacamole::Collection

  map do
    references :author
  end
end

describe 'Associations' do

  let(:author) { Fabricate(:author_with_three_books) }

  it 'should load referenced models from the database' do
    pending 'Not yet implemented'

    the_author        = AuthorsCollection.by_key author.key
    books_from_author = BooksCollection.by_example(author_id: author.key).to_a

    expect(books_from_author).to eq the_author.books
  end

  it 'should load the referenced model fro the database' do
    pending 'Not yet implemented'
  end
end
