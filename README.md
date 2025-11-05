# Aether

Aether is a ruby ​​library for implementing cursor pagination, which is faster and more scalable than offset pagination.

With the Aether library, pagination with large datasets is no longer a bottleneck.

## High Flow

Potential problems when using offset pagination : 

![Logo Ruby](https://github.com/solehudinmq/aether/blob/development/high_flow/Aether-problem.jpg)

Cursor pagination is a solution for implementing pagination for large data :

![Logo Ruby](https://github.com/solehudinmq/aether/blob/development/high_flow/Aether-solution.jpg)

## Requirement

The minimum version of Ruby that must be installed is 3.0.

Requires dependencies to the following gems :
- activerecord

- activesupport

## Installation

Add this line to your application's Gemfile :

```ruby
# Gemfile
gem 'aether', git: 'git@github.com:solehudinmq/aether.git', branch: 'main'
```

Open terminal, and run this : 

```bash
cd your_ruby_application
bundle install
```

## Create Table with Column cursor_timestamp

Make sure that in the table where you will implement cursor pagination, there are columns named id and cursor_timestamp, where the cursor_timestamp column contains the epoch timestamp. Example of creating a table with cursor_timestamp column in PostgreSQL database :

```bash
CREATE TABLE your_table (
  id SERIAL PRIMARY KEY,
  column1 VARCHAR(255) NOT NULL,
  column2 TEXT,
  cursor_timestamp INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

For more details, you can see the following example : [example/new_table.txt](Here).

Or if the table already exists, you can do an alter table like the following example :

```bash
ALTER TABLE your_table
ADD COLUMN cursor_timestamp INTEGER NOT NULL;
```

For more details, you can see the following example : [example/existing_table.txt](Here).

## Create Index

To speed up query performance, we can add indexing for cursor_timestamp and id. Example of creating an index for a PostgreSQL database :

```bash
CREATE INDEX idx_your_table_on_cursor_timestamp_and_id
ON your_table (cursor_timestamp, id);
```

For more details, you can see the following example : [example/post_index.txt](Here).

## Usage

In the model that will implement cursor pagination add this :

```ruby
require 'aether'

class YourModel < ActiveRecord::Base
  include Aether
end
```

For more details, you can see the following example : [example/post.rb](Here).

How to use cursor pagination :

```ruby
result = YourModel.cursor_paginate(
  cursor_timestamp: cursor_timestamp,
  cursor_id: cursor_id,
  direction: direction,
  limit: limit,
  order_by: order_by
)
```
Parameter description :
- cursor_timestamp (optional) : is a parameter that contains cursor timestamp information in the form of an epoch timestamp. Example: 1756722030.
- cursor_id (optional) = is a parameter that contains cursor ID information. Example: 5.
- direction (optional) = This parameter contains information about the cursor to retrieve the next or previous data. Example: 'next' / 'previous'.
- limit (optional) = is a parameter that contains information about the amount of data that will be displayed. Example: 5.
- order_by (optional) = is a parameter that contains information about how to order data. Example: 'asc' / 'desc'.

For more details, you can see the following example : [example/app.rb](Here).

## Column cursor_timestamp Values

How to fill in data for the cursor_timestamp column :

```ruby
  YourModel.create(column1: "value1", cursor_timestamp: Time.now.to_i)
```

## Example Implementation in Your Application

For examples of applications that use this gem, you can see them here : [example](Here).

## Example of Cursor Pagination Response

For examples of applications that use this gem, you can see them here : [example/response.json](Here).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solehudinmq/aether.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
