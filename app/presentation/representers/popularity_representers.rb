# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module MerciDanke
  module Entity
    # each pokemon hast it popularity value
    class Popularity < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :poke_id, Strict::Integer
      attribute :popularity_level, String.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
