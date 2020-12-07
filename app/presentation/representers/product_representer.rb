# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MerciDanke
  module Representer
    # Represents about pokemons' product
    class Product < Roar::Decorator
      include Roar::JSON

      property :origin_id
      property :poke_name
      property :title
      property :link
      property :image
      property :rating
      property :ratings_total
      property :price
      property :product_likes
    end
  end
end
