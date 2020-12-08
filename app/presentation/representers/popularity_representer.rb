# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'pokemon_representer'

module MerciDanke
  module Representer
    # each pokemon hast it popularity value
    class Popularity < Roar::Decorator
      include Roar::JSON

      # pokemon may not be called我覺得不行
      property :pokemon, extend: Representer::Pokemon, class: OpenStruct
      property :poke_id
      property :popularity_level
    end
  end
end
