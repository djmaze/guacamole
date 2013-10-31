# -*- encoding: utf-8 -*-

class Book
  include Guacamole::Model
  include Guacamole::Model

  autoload :Author, 'fabricators/author'

  attribute :title, String
  attribute :author, Author
end
