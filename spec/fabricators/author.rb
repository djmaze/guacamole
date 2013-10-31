# -*- encoding: utf-8 -*-

class Author
  extend ActiveSupport::Autoload
  include Guacamole::Model

  autoload :Book, 'fabricators/book'

  attribute :name, String
  attribute :books, Array[Book]
end
