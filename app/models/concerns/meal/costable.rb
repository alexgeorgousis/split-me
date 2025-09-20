module Meal::Costable
  extend ActiveSupport::Concern

  def calculate_cost_from_receipt(order)
    return 0.0 unless order&.receipt_processed?

    total_cost = 0.0

    meal_ingredients.includes(:ingredient).each do |meal_ingredient|
      ingredient = meal_ingredient.ingredient

      # Find the matching receipt item for this ingredient
      matched_receipt_item = find_best_receipt_match(ingredient, order)

      next unless matched_receipt_item

      # Add the full cost of the receipt item (quantity doesn't matter)
      total_cost += matched_receipt_item.price * matched_receipt_item.quantity
    end

    total_cost.round(2)
  end

  def cost_breakdown_for_receipt(order)
    return {} unless order&.receipt_processed?

    breakdown = {}

    meal_ingredients.includes(:ingredient).each do |meal_ingredient|
      ingredient = meal_ingredient.ingredient

      matched_receipt_item = find_best_receipt_match(ingredient, order)

      if matched_receipt_item
        total_item_cost = matched_receipt_item.price * matched_receipt_item.quantity

        breakdown[ingredient.name] = {
          matched_item: matched_receipt_item.name,
          total_cost: total_item_cost.round(2),
          confidence: find_match_confidence(ingredient, matched_receipt_item)
        }
      else
        breakdown[ingredient.name] = {
          matched_item: nil,
          total_cost: 0.0,
          confidence: 0.0
        }
      end
    end

    breakdown
  end

  def has_all_ingredients_matched?(order)
    return false unless order&.receipt_processed?

    meal_ingredients.all? do |meal_ingredient|
      find_best_receipt_match(meal_ingredient.ingredient, order).present?
    end
  end

  def missing_ingredients_for_receipt(order)
    return [] unless order&.receipt_processed?

    meal_ingredients.includes(:ingredient).select do |meal_ingredient|
      find_best_receipt_match(meal_ingredient.ingredient, order).nil?
    end.map(&:ingredient)
  end

  private

  def find_best_receipt_match(ingredient, order)
    # Find the best matching receipt item through ingredient matches
    best_match = ingredient.ingredient_matches
                          .joins(:receipt_item)
                          .where(receipt_items: { order: order })
                          .order(confidence: :desc)
                          .first

    best_match&.receipt_item
  end

  def find_match_confidence(ingredient, receipt_item)
    match = ingredient.ingredient_matches
                     .find_by(receipt_item: receipt_item)

    match&.confidence || 0.0
  end
end
