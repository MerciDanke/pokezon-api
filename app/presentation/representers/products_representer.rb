# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'product_representer'

module MerciDanke
  module Representer
    # Represents list of products for API output
    class ProductsList < Roar::Decorator
      include Roar::JSON

      collection :products, extend: Representer::Product,
                            class: Representer::OpenStructWithLinks
    end
  end
end
