# frozen_string_literal: false

module MerciDanke
  module Entity
    # Domain entity for any coding projects
    class Product < Dry::Struct
      include Dry.Types

      attribute :id,        Integer.optional
      attribute :origin_id, Strict::String
      attribute :poke_name, Strict::String
      attribute :title,     Strict::String
      attribute :link,      Strict::String
      attribute :image,     Strict::String
      attribute :rating,    Strict::Float
      attribute :ratings_total, Strict::Integer
      # attribute :price, Strict::Float
      # attribute :currency, Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
