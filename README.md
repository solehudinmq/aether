# Aether

Aether is a ruby ​​library for implementing cursor pagination, which is faster and more scalable than offset pagination.

With the Aether library, pagination with large datasets is no longer a bottleneck.

## High Flow

Potential problems when using offset pagination : 
![Logo Ruby](https://github.com/solehudinmq/aether/blob/development/high_flow/Aether-problem.jpg)

Cursor pagination is a solution for implementing pagination for large data :
![Logo Ruby](https://github.com/solehudinmq/aether/blob/development/high_flow/Aether-solution.jpg)

## Installation

The minimum version of Ruby that must be installed is 3.0.
Only runs on activerecord.

Add this line to your application's Gemfile :

```ruby
gem 'aether', git: 'git@github.com:solehudinmq/aether.git', branch: 'main'
```

Open terminal, and run this : 
```bash
cd your_ruby_application
bundle install
```

Make sure that in the table where you will implement cursor pagination, there are columns named id and cursor_timestamp, where the cursor_timestamp column contains the epoch timestamp. Example of creating a table with cursor_timestamp column in PostgreSQL database :

```bash
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT,
  cursor_timestamp INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

Or if the table already exists, you can do an alter table like the following example :

```bash
ALTER TABLE posts
ADD COLUMN cursor_timestamp INTEGER NOT NULL;
```

To speed up query performance, we can add indexing for cursor_timestamp and id. Example of creating an index for a PostgreSQL database :

```bash
CREATE INDEX idx_posts_on_cursor_timestamp_and_id
ON posts (cursor_timestamp, id);
```

## Usage

In the model that will implement cursor pagination add this :

```ruby
require 'aether'

class YourModel < ActiveRecord::Base
  include Aether
end
```

How to use cursor pagination :
```ruby
result = YourModel.cursor_paginate(
    cursor_timestamp: 1756722029,
    cursor_id: 5,
    direction: 'next',
    limit: 10,
    order_by: 'asc'
)
```
Parameter description :
- cursor_timestamp (optional) : is a parameter that contains cursor timestamp information in the form of an epoch timestamp. Example: 1756722030.
- cursor_id (optional) = is a parameter that contains cursor ID information. Example: 5.
- direction (optional) = This parameter contains information about the cursor to retrieve the next or previous data. Example: 'next' / 'previous'.
- limit (optional) = is a parameter that contains information about the amount of data that will be displayed. Example: 5.
- order_by (optional) = is a parameter that contains information about how to order data. Example: 'asc' / 'desc'.

How to fill in data for the cursor_timestamp column :

```ruby
  Post.create(content: "Test", cursor_timestamp: Time.now.to_i)
```

Example of usage in your application :
```ruby
# post.rb
require 'aether'

class Post < ActiveRecord::Base
  include Aether
end
```

```ruby
# app.rb
require 'sinatra'
require 'json'
require_relative 'post'

get '/posts' do
  begin
    posts = Post.cursor_paginate(
      cursor_timestamp: params[:cursor_timestamp],
      cursor_id: params[:cursor_id],
      direction: params[:direction],
      limit: params[:limit],
      order_by: params[:order_by]
    )

    content_type :json
    posts.to_json
  rescue => e
    content_type :json
    status 500
    return { error: e.message }.to_json
  end
end
```

Example of pagination cursor response : 
```json
{
    "data": [
        {
            "id": 1,
            "content": "Post 15",
            "cursor_timestamp": 1756722028,
            "created_at": "2025-09-01T10:20:28.708Z",
            "updated_at": "2025-09-01T10:20:28.708Z"
        },
        {
            "id": 2,
            "content": "Post 14",
            "cursor_timestamp": 1756722028,
            "created_at": "2025-09-01T10:20:28.809Z",
            "updated_at": "2025-09-01T10:20:28.809Z"
        },
        {
            "id": 3,
            "content": "Post 13",
            "cursor_timestamp": 1756722028,
            "created_at": "2025-09-01T10:20:28.910Z",
            "updated_at": "2025-09-01T10:20:28.910Z"
        },
        {
            "id": 4,
            "content": "Post 12",
            "cursor_timestamp": 1756722029,
            "created_at": "2025-09-01T10:20:29.011Z",
            "updated_at": "2025-09-01T10:20:29.011Z"
        },
        {
            "id": 5,
            "content": "Post 11",
            "cursor_timestamp": 1756722029,
            "created_at": "2025-09-01T10:20:29.111Z",
            "updated_at": "2025-09-01T10:20:29.111Z"
        }
    ],
    "next_cursor": {
        "cursor_timestamp": 1756722029,
        "cursor_id": 5,
        "direction": "next"
    },
    "previous_cursor": {
        "cursor_timestamp": 1756722028,
        "cursor_id": 1,
        "direction": "previous"
    }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/aether.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
