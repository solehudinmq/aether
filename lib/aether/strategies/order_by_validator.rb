class OrderByValidator
    def self.validate(order_by)
        unless ['asc', 'desc'].include?(order_by)
          raise "order_by parameter must contain asc/desc."
        end
    end
end