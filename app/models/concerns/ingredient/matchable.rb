module Ingredient::Matchable
  extend ActiveSupport::Concern

  class_methods do
    def find_matches_for_receipt_item(receipt_item)
      Ingredient.select { |ingredient| matches?(receipt_item, ingredient) }
    end

    def auto_match_receipt_item!(receipt_item)
      matches = find_matches_for_receipt_item(receipt_item)

      return nil if matches.empty?

      # Take the first match (or could randomize if multiple matches)
      matched_ingredient = matches.first

      # Create the match record
      IngredientMatch.create!(
        receipt_item: receipt_item,
        ingredient: matched_ingredient,
        confidence: 1.0
      )
    end

    def matches?(receipt_item, ingredient)
      receipt_words = extract_words(receipt_item.name)
      ingredient_words = extract_words(ingredient.name)

      return false if ingredient_words.empty?

      all_ingredient_words_found?(ingredient_words, receipt_words)
    end

    private

    def extract_words(text)
      text.downcase
          .gsub(/[^\w\s]/, ' ')
          .split
          .reject(&:blank?)
    end

    def all_ingredient_words_found?(ingredient_words, receipt_words)
      ingredient_words.all? { |ingredient_word|
        receipt_words.any? { |receipt_word| receipt_word.include?(ingredient_word) }
      }
    end
  end

  def best_receipt_item_match
    ingredient_matches.order(confidence: :desc).first&.receipt_item
  end

  def total_matched_price
    ingredient_matches.includes(:receipt_item).sum do |match|
      match.receipt_item.price * match.receipt_item.quantity
    end
  end
end