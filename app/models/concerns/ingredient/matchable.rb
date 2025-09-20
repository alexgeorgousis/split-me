module Ingredient::Matchable
  extend ActiveSupport::Concern

  class_methods do
    def find_matches_for_receipt_item(receipt_item, threshold: 0.6)
      ingredient_name = receipt_item.name.downcase
      matches = []

      Ingredient.find_each do |ingredient|
        confidence = calculate_similarity(ingredient_name, ingredient.name.downcase)

        if confidence >= threshold
          matches << {
            ingredient: ingredient,
            confidence: confidence
          }
        end
      end

      # Sort by confidence, highest first
      matches.sort_by { |match| -match[:confidence] }
    end

    def auto_match_receipt_item!(receipt_item, min_confidence: 0.8)
      matches = find_matches_for_receipt_item(receipt_item, threshold: min_confidence)

      return nil if matches.empty?

      best_match = matches.first

      # Create the match record
      IngredientMatch.create!(
        receipt_item: receipt_item,
        ingredient: best_match[:ingredient],
        confidence: best_match[:confidence]
      )
    end

    private

    def calculate_similarity(str1, str2)
      # Simple token-based similarity
      tokens1 = tokenize(str1)
      tokens2 = tokenize(str2)

      return 1.0 if tokens1 == tokens2
      return 0.0 if tokens1.empty? || tokens2.empty?

      # Jaccard similarity
      intersection = (tokens1 & tokens2).size
      union = (tokens1 | tokens2).size

      intersection.to_f / union
    end

    def tokenize(string)
      string.downcase
            .gsub(/[^\w\s]/, ' ')  # Replace punctuation with spaces
            .split(/\s+/)           # Split on whitespace
            .reject(&:blank?)       # Remove empty strings
            .uniq                   # Remove duplicates
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