# frozen_string_literal: true

require 'sequel'

module MerciDanke
  module Database
    # Object Relational Mapper for Product Entities
    class ProductOrm < Sequel::Model(:products)
      plugin :timestamps, update_on_create: true
    end
  end
end
