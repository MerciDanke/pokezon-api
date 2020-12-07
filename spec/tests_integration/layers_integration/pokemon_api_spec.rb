# frozen_string_literal: false

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper.rb'

describe 'Tests Pokemon API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Pokemon information' do
    it 'HAPPY: should provide correct pokemon attributes' do
      # pokemontest = PokemonInf::PokemonApi.new.pokemon(ID)
      pokemontest = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_NAME)

      _(pokemontest.origin_id).must_equal CORRECT['id']
      _(pokemontest.poke_name).must_equal CORRECT['name']
      _(pokemontest.height).must_equal CORRECT['height']
      _(pokemontest.weight).must_equal CORRECT['weight']
      _(pokemontest.habitat).must_equal CORRECT['habitat']
      _(pokemontest.color).must_equal CORRECT['color']
      _(pokemontest.flavor_text_entries).must_equal CORRECT['flavor_text_entries']
      _(pokemontest.genera).must_equal CORRECT['genera']
      _(pokemontest.back_default).must_equal CORRECT['back_default']
      _(pokemontest.back_shiny).must_equal CORRECT['back_shiny']
      _(pokemontest.front_default).must_equal CORRECT['front_default']
      _(pokemontest.front_shiny).must_equal CORRECT['front_shiny']
      _(pokemontest.poke_likes).must_be_kind_of Integer
    end
    it 'SAD: should raise exception on incorrect id' do
      _(proc do
        MerciDanke::Pokemon::PokemonMapper.new.find('foobar')
      end).must_raise MerciDanke::Pokemon::Api::Response::NotFound
    end
  end
  describe 'abilities information' do
    before do
      @pokemon = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_NAME)
    end

    it 'HAPPY: should recognize abilities' do
      _(@pokemon.abilities).must_be_kind_of Array
    end

    it 'HAPPY: should identify abilities' do
      ability = @pokemon.abilities[0]
      _(ability.origin_id).wont_be_nil
      _(ability.ability_name).must_be_kind_of String
      _(ability.flavor_text_entries).must_be_kind_of String
      _(ability.ability_pokemons).must_be_kind_of Array
    end
  end
  describe 'types information' do
    before do
      @pokemon = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_NAME)
    end

    it 'HAPPY: should recognize types' do
      _(@pokemon.types).must_be_kind_of Array
    end

    it 'HAPPY: should identify types' do
      _(@pokemon.types[0].type_name).must_be_kind_of String
    end
  end
  describe 'evochain information' do
    before do
      @pokemon = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_NAME)
    end

    it 'HAPPY: should recognize evochain' do
      _(@pokemon.evochain).must_be_kind_of MerciDanke::Entity::Evochain
    end

    it 'HAPPY: should identify evochain' do
      _(@pokemon.evochain.origin_id).wont_be_nil
      _(@pokemon.evochain.chain_species_name).must_be_kind_of String
    end
  end
end
