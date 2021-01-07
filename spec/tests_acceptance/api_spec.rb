# frozen_string_literal: true

require_relative '../helpers/spec_helper'
require_relative '../helpers/vcr_helper'
require_relative '../helpers/database_helper'
require 'rack/test'

def app
  MerciDanke::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey
    DatabaseHelper.wipe_database
    pokemon = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_ID)
    MerciDanke::SearchRecord::ForPoke.entity(pokemon).create(pokemon)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Pokemon detail route' do
    it 'should be able to show pokemon info and popularity' do
      MerciDanke::Service::PokemonPopularity.new.call(poke_name: POKE_NAME)

      get "/api/v1/pokemon/#{POKE_NAME}"
      _(last_response.status).must_equal 200
      pokemon = JSON.parse last_response.body
      _(pokemon.keys.sort).must_equal %w[pokemon popularity]
      _(pokemon['pokemon']['id']).must_be_kind_of Integer
      _(pokemon['pokemon']['origin_id']).must_equal 1
      _(pokemon['pokemon']['poke_name']).must_equal POKE_NAME
      _(pokemon['pokemon']['types'].count).must_equal 2
      _(pokemon['pokemon']['height']).must_equal 7
      _(pokemon['pokemon']['weight']).must_equal 69
      _(pokemon['pokemon']['back_default']).must_include 'png'
      _(pokemon['pokemon']['back_shiny']).must_include 'png'
      _(pokemon['pokemon']['front_default']).must_include 'png'
      _(pokemon['pokemon']['front_shiny']).must_include 'png'
      _(pokemon['pokemon']['evochain'].count).must_equal 4
      _(pokemon['pokemon']['habitat']).must_equal 'grassland'
      _(pokemon['pokemon']['color']).must_equal 'green'
      _(pokemon['pokemon']['flavor_text_entries']).must_be_kind_of String
      _(pokemon['pokemon']['genera']).must_equal 'Seed Pokémon'
      _(pokemon['pokemon']['abilities'].count).must_equal 2
      _(pokemon['pokemon']['poke_likes']).must_be_kind_of Integer
      _(pokemon['popularity']['poke_id']).must_equal 1
      _(pokemon['popularity']['popularity_level']).must_be_kind_of String
      _(pokemon['pokemon']['links'].count).must_equal 1
    end

    it 'should be report error for an invalid pokemon name' do
      MerciDanke::Service::PokemonPopularity.new.call(poke_name: 'foobar')

      get '/api/v1/pokemon/foobar'
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Basic Pokemon route' do
    it 'should be able to show pokemon basic info and popularities' do
      MerciDanke::Service::BasicPokemonPopularity.new.call

      get '/api/v1/pokemon'
      _(last_response.status).must_equal 200
      pokemon = JSON.parse last_response.body
      _(pokemon.keys.sort).must_equal %w[pokemon_list popularity_list]
      _(pokemon['pokemon_list'][0]['id']).must_be_kind_of Integer
      _(pokemon['pokemon_list'][0]['origin_id']).must_equal 1
      _(pokemon['pokemon_list'][0]['poke_name']).must_equal POKE_NAME
      _(pokemon['pokemon_list'][0]['front_default']).must_include 'png'
      _(pokemon['pokemon_list'][0]['poke_likes']).must_be_kind_of Integer
      _(pokemon['popularity_list'][0]['poke_id']).must_equal 1
      _(pokemon['popularity_list'][0]['popularity_level']).must_be_kind_of String
      _(pokemon['pokemon_list'][0]['links'].count).must_equal 1
    end

    it 'should be able to show specific pokemon basic info and popularities' do
      MerciDanke::Service::BasicPokemonPopularity.new.call

      get '/api/v1/pokemon?color=green'
      _(last_response.status).must_equal 200
      pokemon = JSON.parse last_response.body
      _(pokemon['pokemon_list'].count).must_equal pokemon['popularity_list'].count
    end
  end

  describe 'products route' do
    it 'should be able to show products that are already stored in db' do
      am_products = MerciDanke::Amazon::ProductMapper.new.find(POKE_NAME, MerciDanke::App.config.API_KEY)
      am_products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }
      MerciDanke::Service::ShowProducts.new.call(poke_name: POKE_NAME)

      get "api/v1/products/#{POKE_NAME}"

      _(last_response.status).must_equal 200

      products = JSON.parse last_response.body
      _(products['products'].class).must_equal Array
      _(products['products'][0]['poke_name']).must_equal POKE_NAME
    end

    it 'should be able to show products that are in processing' do
      MerciDanke::Service::ShowProducts.new.call(poke_name: 'pidgey')

      get "api/v1/products/#{POKE_NAME}"

      _(last_response.status).must_equal 202

      products = JSON.parse last_response.body
      _(products['message'].class).must_equal Integer
    end
    it 'should be able to show products that are been sorted by rating ' do
      am_products = MerciDanke::Amazon::ProductMapper.new.find(POKE_NAME, MerciDanke::App.config.API_KEY)
      am_products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }
      MerciDanke::Service::ProductsSort.new.call(poke_name: POKE_NAME)

      get "api/v1/products/#{POKE_NAME}?sort=rating_DESC"

      _(last_response.status).must_equal 200

      products = JSON.parse last_response.body
      _(products['products'].class).must_equal Array
      assert_operator products['products'][0]['rating'], :>=, products['products'][1]['rating']
    end

    it 'should report error for invalid pokemon name' do
      MerciDanke::Service::ShowProducts.new.call(poke_name: 'foobar')

      get 'api/v1/products/foobar'

      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end
  describe 'likes route' do
    it 'should be able to plus pokemon like' do
      MerciDanke::Service::PokemonLike.new.call(target_id: POKE_ID)
      put 'api/v1/pokemon/1/likes'
      _(last_response.status).must_equal 200
      _(JSON.parse(last_response.body)['message']).must_include 'plus'
    end
    it 'should be able to plus product like' do
      am_products = MerciDanke::Amazon::ProductMapper.new.find(POKE_NAME, MerciDanke::App.config.API_KEY)
      am_products.map { |prod| MerciDanke::SearchRecord::For.entity(prod).create(prod) }
      MerciDanke::Service::ProductLike.new.call(target_id: PRODUCT_OID)

      put "api/v1/product/#{PRODUCT_OID}/likes"
      _(last_response.status).must_equal 200
      _(JSON.parse(last_response.body)['message']).must_include 'plus'
    end
  end
end
