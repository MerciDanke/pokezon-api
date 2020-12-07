# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module MerciDanke
  module Representer
    # Represents about pokemons' abilities
    # USAGE:
    #   member = Database::MemberOrm.find(1)
    #   Representer::Member.new(member).to_json
    class Ability < Roar::Decorator
      include Roar::JSON

      property :origin_id
      property :ability_name
      property :flavor_text_entries
      collection :ability_pokemons
    end
  end
end
