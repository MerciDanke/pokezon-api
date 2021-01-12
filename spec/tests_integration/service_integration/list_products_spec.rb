# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

require 'ostruct'

describe 'Search Google Shopping Products Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey(recording: :none)
    pokemon = MerciDanke::Pokemon::PokemonMapper.new.find(POKE_ID)
    MerciDanke::SearchRecord::ForPoke.entity(pokemon).create(pokemon)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Search Products' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should return products that are being watched' do
      # GIVEN: valid products exist locally and is being watched
      products = MerciDanke::GoogleShopping::ProductMapper.new.find(POKE_NAME, API_KEY)
      product = products[0]

      db_product = MerciDanke::SearchRecord::For.entity(product)
        .create(product)
      watched_list = [POKE_NAME]

      # WHEN: we request a list of all watched products
      result = MerciDanke::Service::ShowProducts.new.call(poke_name: watched_list)
      puts result.value!
      # THEN: we should see our product in the resulting list
      _(result.success?).must_equal true
      products = result.value!
      _(products[0][0].origin_id).must_include db_product.origin_id
    end

    it 'HAPPY: should not return products that are not being watched' do
      # GIVEN: valid products exist locally but is not being watched
      products = MerciDanke::GoogleShopping::ProductMapper.new.find(POKE_NAME, API_KEY)
      # amz_products = MerciDanke::Amazon::ProductMapper
      #   .new.find(POKE_NAME, API_KEY)
      products.map do |product|
        MerciDanke::SearchRecord::For.entity(product)
          .create(product)
      end
      watched_list = []

      # WHEN: we request a list of all watched products
      result = MerciDanke::Service::ShowProducts.new.call(poke_name: watched_list)
      puts result.value!
      # THEN: it should return an empty list
      _(result.success?).must_equal true
      products = result.value!
      _(products).must_equal []
    end

    it 'SAD: should not watched products if they are not loaded' do
      # GIVEN: we are watching a product that does not exist locally
      watched_list = [POKE_NAME]

      # WHEN: we request a list of all watched products
      result = MerciDanke::Service::ShowProducts.new.call(poke_name: watched_list)
      puts result.value!
      # THEN: it should return an empty list
      _(result.success?).must_equal true
      products = result.value!
      _(products).must_equal [[]]
    end
  end
end
