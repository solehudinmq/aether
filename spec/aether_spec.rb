# frozen_string_literal: true

require_relative '../lib/aether'

RSpec.describe Aether do
  before(:all) do
    # Delete old data and enter new data
    Post.destroy_all
    15.times do |i|
      Post.create(content: "Post #{15-i}", cursor_timestamp: Time.now.to_i)
      sleep(0.1) # Add a gap to make the created_at different
    end
    'Database seeded with 15 posts.'

    @posts = Post.all
  end

  it "has a version number" do
    expect(Aether::VERSION).not_to be nil
  end

  it "return the first 10 data without sending any parameters" do
    posts = Post.cursor_paginate
    data = posts[:data]
  
    expect(data.length).to be 10

    expect(data[0].id).to be @posts[0].id
    expect(data[9].id).to be @posts[9].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "return the first 5 data by sending the limit parameter is 5" do
    posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: nil)
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[0].id
    expect(data[4].id).to be @posts[4].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "return the first 5 data by sending the limit parameter is 5 and the order_by parameter is asc" do
    posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'asc')
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[0].id
    expect(data[4].id).to be @posts[4].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "return the first 5 data by sending the limit parameter is 5 and the order_by parameter is desc" do
    posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'desc')
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[-1].id
    expect(data[4].id).to be @posts[-5].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "returns 5 data by sending the next cursor parameter and in asc order" do
    first_call_posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'asc')

    posts = Post.cursor_paginate(cursor_timestamp: first_call_posts[:next_cursor][:cursor_timestamp], cursor_id: first_call_posts[:next_cursor][:cursor_id], direction: first_call_posts[:next_cursor][:direction], limit: 5, order_by: 'asc')
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[5].id
    expect(data[4].id).to be @posts[9].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "returns 5 data by sending the next cursor parameter and in desc order" do
    first_call_posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'desc')
    
    posts = Post.cursor_paginate(cursor_timestamp: first_call_posts[:next_cursor][:cursor_timestamp], cursor_id: first_call_posts[:next_cursor][:cursor_id], direction: first_call_posts[:next_cursor][:direction], limit: 5, order_by: 'desc')
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[-6].id
    expect(data[4].id).to be @posts[-10].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "returns 5 data by sending the previous cursor parameter and in asc order" do
    first_call_posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'asc')

    second_call_posts = Post.cursor_paginate(cursor_timestamp: first_call_posts[:next_cursor][:cursor_timestamp], cursor_id: first_call_posts[:next_cursor][:cursor_id], direction: first_call_posts[:next_cursor][:direction], limit: 5, order_by: 'asc')
    
    posts = Post.cursor_paginate(cursor_timestamp: second_call_posts[:previous_cursor][:cursor_timestamp], cursor_id: second_call_posts[:previous_cursor][:cursor_id], direction: second_call_posts[:previous_cursor][:direction], limit: 5, order_by: 'asc')
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[0].id
    expect(data[4].id).to be @posts[4].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it "returns 5 data by sending the previous cursor parameter and in desc order" do
    first_call_posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'desc')

    second_call_posts = Post.cursor_paginate(cursor_timestamp: first_call_posts[:next_cursor][:cursor_timestamp], cursor_id: first_call_posts[:next_cursor][:cursor_id], direction: first_call_posts[:next_cursor][:direction], limit: 5, order_by: 'desc')
    
    posts = Post.cursor_paginate(cursor_timestamp: second_call_posts[:previous_cursor][:cursor_timestamp], cursor_id: second_call_posts[:previous_cursor][:cursor_id], direction: second_call_posts[:previous_cursor][:direction], limit: 5, order_by: 'desc')
    data = posts[:data]
  
    expect(data.length).to be 5

    expect(data[0].id).to be @posts[-1].id
    expect(data[4].id).to be @posts[-5].id

    expect(posts[:next_cursor]).not_to be nil
    expect(posts[:next_cursor][:cursor_timestamp]).to be data.last.cursor_timestamp
    expect(posts[:next_cursor][:cursor_id]).to be data.last.id
    expect(posts[:next_cursor][:direction]).to be 'next'

    expect(posts[:previous_cursor]).not_to be nil
    expect(posts[:previous_cursor][:cursor_timestamp]).to be data.first.cursor_timestamp
    expect(posts[:previous_cursor][:cursor_id]).to be data.first.id
    expect(posts[:previous_cursor][:direction]).to be 'previous'
  end

  it 'return 0 data in asc order' do
    first_call_posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'asc')

    posts = Post.cursor_paginate(cursor_timestamp: first_call_posts[:previous_cursor][:cursor_timestamp], cursor_id: first_call_posts[:previous_cursor][:cursor_id], direction: first_call_posts[:previous_cursor][:direction], limit: 5, order_by: 'asc')
    data = posts[:data]
  
    expect(data.length).to be 0

    expect(posts[:next_cursor]).to be nil
    expect(posts[:previous_cursor]).to be nil
  end

  it 'return 0 data in desc order' do
    first_call_posts = Post.cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: 5, order_by: 'desc')
    posts = Post.cursor_paginate(cursor_timestamp: first_call_posts[:previous_cursor][:cursor_timestamp], cursor_id: first_call_posts[:previous_cursor][:cursor_id], direction: first_call_posts[:previous_cursor][:direction], limit: 5, order_by: 'desc')
    data = posts[:data]
  
    expect(data.length).to be 0

    expect(posts[:next_cursor]).to be nil
    expect(posts[:previous_cursor]).to be nil
  end
end
