# frozen_string_literal: true

require_relative '../../helpers/spec_helper.rb'
require_relative '../../helpers/vcr_helper.rb'
require_relative '../../helpers/database_helper.rb'

describe 'ShowProduct Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store products' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to find and save remote product to database' do
      # GIVEN: a valid url request for an existing remote product:
      product = MerciDanke::Amazon::ProductMapper
        .new.find(POKE_NAME, API_KEY).first
      url_request = MerciDanke::Forms::SearchProduct.new.call(poke_name: POKE_NAME)

      # WHEN: the service is called with the request form object
      product_made = MerciDanke::Service::ShowProducts.new.call(url_request)

      # THEN: the result should report success..
      _(product_made.success?).must_equal true

      # ..and provide a product entity with the right details
      rebuilt = product_made.value![0]

      _(rebuilt.origin_id).must_equal(product.origin_id)
      _(rebuilt.title).must_equal(product.title)
      _(rebuilt.poke_name).must_equal(product.poke_name)
      _(rebuilt.link).must_equal(product.link)
      _(rebuilt.image).must_equal(product.image)
      _(rebuilt.rating).must_equal(product.rating)
      _(rebuilt.ratings_total).must_equal(product.ratings_total)
      _(rebuilt.price).must_equal(product.price)
      _(rebuilt.product_likes).must_equal(product.product_likes)
    end

    it 'HAPPY: should find and return existing product in database' do
      # GIVEN: a valid url request for a product already in the database:
      url_request = MerciDanke::Forms::SearchProduct.new.call(poke_name: POKE_NAME)
      db_product = MerciDanke::Service::ShowProducts.new.call(url_request).value![0]

      # WHEN: the service is called with the request form object
      product_made = MerciDanke::Service::ShowProducts.new.call(url_request)

      # THEN: the result should report success..
      _(product_made.success?).must_equal true

      # ..and find the same product that was already in the database
      rebuilt = product_made.value![0]
      _(rebuilt.id).must_equal(db_product.id)

      # ..and provide a product entity with the right details
      _(rebuilt.origin_id).must_equal(db_product.origin_id)
      _(rebuilt.title).must_equal(db_product.title)
      _(rebuilt.poke_name).must_equal(db_product.poke_name)
      _(rebuilt.link).must_equal(db_product.link)
      _(rebuilt.image).must_equal(db_product.image)
      _(rebuilt.rating).must_equal(db_product.rating)
      _(rebuilt.ratings_total).must_equal(db_product.ratings_total)
      _(rebuilt.price).must_equal(db_product.price)
      _(rebuilt.product_likes).must_equal(db_product.product_likes)
    end

    it 'BAD: should gracefully fail for invalid product url' do
      # GIVEN: an invalid url request is formed
      BAD_POKE_NAME = 'foobar'
      url_request = MerciDanke::Forms::SearchProduct.new.call(poke_name: BAD_POKE_NAME)

      # WHEN: the service is called with the request form object
      product_made = MerciDanke::Service::ShowProducts.new.call(url_request)
      # THEN: the service should report failure with an error message
      _(product_made.success?).must_equal false
      _(product_made.failure.downcase).must_include 'could not find'
    end
  end
end
