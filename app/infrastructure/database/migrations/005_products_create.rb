# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:products) do
      primary_key :id

      String      :origin_id, unique: true
      String      :poke_name
      String      :title
      String      :link
      String      :image
      Float       :rating
      Integer     :ratings_total
      String      :price
      Integer     :product_likes

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
