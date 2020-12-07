# frozen_string_literal: false

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'Integration Tests of Pokemon API and Database' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store pokemon' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save pokemon from Pokemon API to database' do
      pokemon = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_NAME)

      rebuilt = MerciDanke::SearchRecord::ForPoke.entity(pokemon).create(pokemon)

      _(rebuilt.origin_id).must_equal(pokemon.origin_id)
      _(rebuilt.poke_name).must_equal(pokemon.poke_name)
      _(rebuilt.weight).must_equal(pokemon.weight)
      _(rebuilt.height).must_equal(pokemon.height)
      _(rebuilt.back_default).must_equal(pokemon.back_default)
      _(rebuilt.back_shiny).must_equal(pokemon.back_shiny)
      _(rebuilt.front_default).must_equal(pokemon.front_default)
      _(rebuilt.front_shiny).must_equal(pokemon.front_shiny)
      _(rebuilt.habitat).must_equal(pokemon.habitat)
      _(rebuilt.color).must_equal(pokemon.color)
      _(rebuilt.flavor_text_entries).must_equal(pokemon.flavor_text_entries)
      _(rebuilt.genera).must_equal(pokemon.genera)
      _(rebuilt.poke_likes).must_equal(pokemon.poke_likes)
      _(rebuilt.evochain.origin_id).must_equal(pokemon.evochain.origin_id)
      _(rebuilt.evochain.chain_species_name).must_equal(pokemon.evochain.chain_species_name)

      pokemon.abilities.each do |ability|
        found = rebuilt.abilities.find do |potential|
          potential.origin_id == ability.origin_id
        end

        _(found.ability_name).must_equal ability.ability_name
        _(found.flavor_text_entries).must_equal ability.flavor_text_entries
      end
      pokemon.types.each do |type|
        found = rebuilt.types.find do |potential|
          potential.type_name == type.type_name
        end
        _(found.type_name).must_equal type.type_name
      end
    end
  end
end
