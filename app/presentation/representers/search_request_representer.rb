# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential products information for API output
module MerciDanke
  module Representer
    # Representer object for project clone requests
    class SearchRequest < Roar::Decorator
      include Roar::JSON

      property :poke_name
      property :id
    end
  end
end
