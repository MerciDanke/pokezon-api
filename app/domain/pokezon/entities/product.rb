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
      attribute :rating,    Float.optional
      attribute :ratings_total, Integer.optional
      attribute :price, String.optional
      attribute :product_likes, Integer.optional

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
