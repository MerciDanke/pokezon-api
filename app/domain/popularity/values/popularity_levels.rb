# frozen_string_literal: true

module MerciDanke
  module Value
    # Define popularity levels
    class PopularityLevels
      def initialize(poke_id, average_rating, products_num, poke_likes_num, products_likes_num)
        @poke_id = poke_id
        @average_rating = average_rating
        @products_num = products_num
        @poke_likes_num = poke_likes_num
        @products_likes_num = products_likes_num
      end

      def popularity_level_hash
        { poke_id: @poke_id, popularity_level: level_rules }
      end

      def level_rules
        if @products_num.zero? then 'Unsearch'
        elsif @average_rating > 2.5 && @products_num >= 10 && @poke_likes_num >= 10 && @products_likes_num > 5 then 'Super Hot'
        elsif @average_rating > 2.0 && @products_num >= 4 && @poke_likes_num >= 7 && @products_likes_num > 3 then 'Hot'
        elsif @average_rating > 1.5 && @products_num >= 2 && @poke_likes_num >= 4 && @products_likes_num > 1 then 'Common'
        else
          'Unpopular'
        end
      end
    end
  end
end
