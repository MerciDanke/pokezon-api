# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

require 'ostruct'

describe 'Search Amazon Products Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey(recording: :none)
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
      amz_products = MerciDanke::Amazon::ProductMapper
        .new.find(POKE_NAME, API_KEY)
      amz_product = amz_products[0]

      db_product = MerciDanke::SearchRecord::For.entity(amz_product)
        .create(amz_product)

      watched_list = [POKE_NAME]

      # WHEN: we request a list of all watched products
      result = MerciDanke::Service::ListProducts.new.call(watched_list)

      # THEN: we should see our product in the resulting list
      _(result.success?).must_equal true
      products = result.value!
      _(products[0][0].origin_id).must_include db_product.origin_id
    end

    it 'HAPPY: should not return products that are not being watched' do
      # GIVEN: valid products exist locally but is not being watched
      amz_products = MerciDanke::Amazon::ProductMapper
        .new.find(POKE_NAME, API_KEY)
      amz_products.map do |product|
        MerciDanke::SearchRecord::For.entity(product)
          .create(product)
      end
      watched_list = []

      # WHEN: we request a list of all watched products
      result = MerciDanke::Service::ListProducts.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      products = result.value!
      _(products).must_equal []
    end

    it 'SAD: should not watched products if they are not loaded' do
      # GIVEN: we are watching a product that does not exist locally
      watched_list = [POKE_NAME]

      # WHEN: we request a list of all watched products
      result = MerciDanke::Service::ListProducts.new.call(watched_list)

      # THEN: it should return an empty list
      _(result.success?).must_equal true
      products = result.value!
      _(products).must_equal [[]]
    end
  end
end
