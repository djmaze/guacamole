# Guacamole

| Project         | Guacamole
|:----------------|:--------------------------------------------------
| Homepage        | https://github.com/triAGENS/guacamole
| Documentation   | [RubyDoc](http://rubydoc.info/gems/guacamole/frames)
| CI              | [![Build Status](https://travis-ci.org/triAGENS/guacamole.png)](https://travis-ci.org/triAGENS/guacamole)
| Code Metrics    | [![Code Climate](https://codeclimate.com/github/triAGENS/guacamole.png)](https://codeclimate.com/github/triAGENS/guacamole)
| Gem Version     | [![Gem Version](https://badge.fury.io/rb/guacamole.png)](http://badge.fury.io/rb/guacamole)
| Dependencies    | [![Dependency Status](https://gemnasium.com/triAGENS/guacamole.png)](https://gemnasium.com/triAGENS/guacamole)
| Ready Stories   | [![Stories in Ready](https://badge.waffle.io/triagens/guacamole.png?label=ready)](https://waffle.io/triagens/guacamole)

Guacamole is an ODM for ArangoDB that offers integration for Ruby on Rails.

All tests run on Travis CI for the following versions of Ruby:

* MRI 1.9.3 and 2.0.0
* Rubinius 1.9 mode
* JRuby 1.9 mode

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'guacamole'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install guacamole
```

## Usage

There are two main concepts you have to be familiar with in Guacamole: Collections and models. Both of these are modules that you can mixed in to your classes:

### Models

Models are representations of your data. They are not aware of the database but work independent of it. A simple example for a model:

```ruby
class Article
  include Guacamole::Model

  attribute :title, String
  attribute :comments, Array[Comment]

  validates :title, presence: true
end
```

This example defines a model called Article, which has a title represented by a String and an array of comments. Comment in this case is another `Guacamole::Model`. The `Model` mixin will also add validation from ActiveModel to your model – it works as you know it from ActiveRecord for example.

In a Rails application, they are stored in the `app/models` directory by convention.

### Collections

Collections are your gateway to the database. They persist your models and offer querying for them. They will translate the raw data from the database to your domain models and vice versa. By convention they are the pluralized version of the model with the suffix `Collection`. So given the model from above, this could be the according collection:

```ruby
class ArticlesCollection
  include Guacamole::Collection

  map do
    embeds :comments
  end
end
```

As you can see above, you don't need to explicitly state that you are mapping to the `Article` class, because this is the naming convention. But what does `map` do?

In the block you provide to `map` you can configure things that should happen when you map from the raw data to the model and vice versa. In a document store like ArangoDB you can have nested data – so the JSON stored in ArangoDB's `articles` collection could look something like this:

```json
{
  "title": "The grand blog post",
  "comments": [
    {
      "text": "This was really a grand blog post"
    },
    {
      "text": "I don't think it was that great"
    }
  ]
```

With the `map` configuration above it would take each of the objects in the comments hash and create instances of the `Comment` model from them. Then it would set the `comments` attribute of the new article and set it to the array of those comments.

In a Rails application, they are stored in the `app/collections` directory by convention. **Note:** As of now you do have to add the `app/collections` path manually to the load path in your `config/application.rb`:

```ruby
config.autoload_paths += Dir[Rails.root.join('app', 'collections', '*.rb').to_s]
```

### Configuration

You configure the connection to ArangoDB in the same fashion as you would configure a connection to a relational database in a Rails application: Just create a YAML file which holds the required parameters for each of your environment:

```yaml
development:
  protocol: 'http'
  host: 'localhost'
  port: 8529
  password: ''
  username: ''
  database: 'planet_express_development'
```

We're looking at `config/guacamole.yml` to read this configuration. If you're using Capistrano or something else make sure you change your deployment recipes accordingly to use the `guacamole.yml` and not the `database.yml`.

**Note:** Currently we're not providing any testing helper, thus you need to make sure to cleanup the database yourself before each run. You can look at the `spec/acceptance/spec_helper.rb` of Guacamole for inspiration of how to do this.

## Issues or Questions

If you find a bug in this gem, please report it on [our tracker](https://github.com/triAGENS/guacamole/issues). We use [Waffle.io](https://waffle.io/triagens/guacamole) to manage the tickets – go there to see the current status of the ticket. If you have a question, just contact us via the [mailing list](https://groups.google.com/forum/?fromgroups#!forum/ashikawa) – we are happy to help you :smile:

## Contributing

If you want to contribute to the project, see CONTRIBUTING.md for details. It contains information on our process and how to set up everything. The following people have contributed to this project:

* Lucas Dohmen ([@moonglum](https://github.com/moonglum)): Developer
* Dirk Breuer ([@railsbros-dirk](https://github.com/railsbros-dirk)): Developer
