# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MerciDanke
  module Representer
    # each pokemon hast it popularity value
    class Popularity < Roar::Decorator
      include Roar::JSON

      property :poke_id
      property :popularity_level
    end
  end
end
