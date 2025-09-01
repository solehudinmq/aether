# frozen_string_literal: true
require 'active_support/concern'

require_relative "aether/version"
require_relative "aether/strategies/direction_validator"
require_relative "aether/strategies/order_by_validator"

module Aether extend ActiveSupport::Concern
  class Error < StandardError; end
  # Your code goes here...

  class_methods do
    def cursor_paginate(cursor_timestamp: nil, cursor_id: nil, direction: nil, limit: nil, order_by: nil)
      limit ||= 10
      order_by ||= 'asc'
      
      # Validation for order_by parameter value
      order_by_validator = OrderByValidator.validate(order_by)

      # Query sorted by asc/desc for column cursor_timestamp & cursor_id.
      data = order(cursor_timestamp: order_by, id: order_by)

      # If the cursor parameter is sent
      if cursor_timestamp && cursor_id && direction
        # Validation for direction parameter value
        direction_validator = DirectionValidator.validate(direction)

        query = find_by_cursor(direction, order_by)

        data = data.where(
          query,
          cursor_timestamp,
          cursor_timestamp,
          cursor_id
        )
      end

      # Return n data according to limit parameter
      result = data.limit(limit)

      # Response for cursor pagination
      next_cursor = nil
      previous_cursor = nil
      if result
        last_data = result.last
        next_cursor = {
          cursor_timestamp: last_data.cursor_timestamp,
          cursor_id: last_data.id,
          direction: 'next'
        }

        first_data = result.first
        previous_cursor = {
          cursor_timestamp: first_data.cursor_timestamp,
          cursor_id: first_data.id,
          direction: 'previous'
        }
      end

      { data: result, next_cursor: next_cursor, previous_cursor: previous_cursor }
    end

    private
      # Query if there is a cursor parameter 
      def find_by_cursor(direction, order_by)
        operator = direction == 'next' ? operator_next_cursor(order_by) : operator_previous_cursor(order_by)

        "(cursor_timestamp #{operator} ?) OR (cursor_timestamp = ? AND id #{operator} ?)"
      end

      # Set operator for next cursor
      def operator_next_cursor(order_by)
        order_by == 'asc' ? '>' : '<'
      end

      # Set operator for previous cursor
      def operator_previous_cursor(order_by)
        order_by == 'asc' ? '<' : '>'
      end
  end
end
