# frozen_string_literal: false

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'Integration Tests of Amazon API and Database' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_apikey
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store Amazon product' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to save products from Amazon API to database' do
      products = MerciDanke::GoogleShopping::ProductMapper.new.find(POKE_NAME, API_KEY)
      product = products[0]
      rebuilt = MerciDanke::SearchRecord::For.entity(product).create(product)
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
  end
end
