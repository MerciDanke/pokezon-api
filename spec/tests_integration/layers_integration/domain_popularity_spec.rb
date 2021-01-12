# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
include MerciDanke, MerciDanke::SearchRecord
describe 'Test popularity Mapper and Gateway' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey
    DatabaseHelper.wipe_database

    products = MerciDanke::GoogleShopping::ProductMapper.new.find(POKE_NAME, API_KEY)
    pokemon = Pokemon::PokemonMapper.new.find(POKE_NAME)
    @db_pokemon = ForPoke.entity(pokemon).create(pokemon)
    products.map { |product| For.entity(product).create(product) }
    @db_products = For.klass(Entity::Product).find_full_name(POKE_NAME)
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should get popularity level for entire repo' do
    root = Mapper::Popularities.new(@db_pokemon, @db_products).build_entity
    _(root.popularity_level).must_equal 'Unpopular'
  end
end
