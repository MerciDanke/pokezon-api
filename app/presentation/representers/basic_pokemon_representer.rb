# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'popularity_representer'

module MerciDanke
  module Representer
    # Represents about basic pokemon info
    class BasicPokemon < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :origin_id
      property :poke_name
      property :front_default

      link :self do
        "#{App.config.API_HOST}/api/v1/pokemon/#{poke_id}"
      end

      private

      def poke_id
        represented.origin_id
      end
    end
  end
end
