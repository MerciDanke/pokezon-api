# frozen_string_literal: true

module MerciDanke
  module Calculate
    # each pokemon's popularity calculation method
    module PopularityCalculator
      # one pokemon's all products average rating
      def cal_average_rating(products)
        return 0 if products.length.zero?

        all_ratings = []
        products.map { |product| all_ratings.push(product.rating) }
        total_rating = all_ratings.reduce { |left, right| left + right }
        (total_rating / cal_products_num(products)).round
      end

      # one pokemon can search how many products
      def cal_products_num(products)
        length = products.length
        return 0 if length.zero?

        length
      end

      # one pokemon's likes count
      def cal_poke_likes_num(pokemon)
        pokemon.poke_likes
      end

      # one pokemon's all products likes count
      def cal_products_likes_num(products)
        return 0 if products.length.zero?

        all_likes = []
        products.map { |product| all_likes.push(product.product_likes) }
        all_likes.reduce { |left, right| left + right }
      end
    end
  end
end
