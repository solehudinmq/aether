class DirectionValidator
    def self.validate(direction)
        unless ['next', 'previous'].include?(direction)
          raise "direction parameter must contain next/previous."
        end
    end
end