# post.rb
require 'sinatra'
require 'active_record'
require 'aether'

# Configure database connections
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

# Create a db directory if it doesn't exist yet
Dir.mkdir('db') unless File.directory?('db')

# Model
class Post < ActiveRecord::Base
  include Aether
end

# Migration to create posts table
ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.table_exists?(:posts)
    create_table :posts do |t|
      t.string :content
      t.integer :cursor_timestamp
      t.timestamps
    end
  end
end