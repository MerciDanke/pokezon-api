# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MerciDanke
  module Representer
    # Represents about pokemons' product
    class Product < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :origin_id
      property :poke_name
      property :title
      property :link
      property :image
      property :rating
      property :ratings_total
      property :price
      property :product_likes

      link :self do
        "#{App.config.API_HOST}/api/v1/products/#{poke_name}"
      end

      private

      def poke_name
        represented.poke_name
      end
    end
  end
end
