module Order::Splittable
  extend ActiveSupport::Concern

  def calculate_meal_costs
    return {} unless receipt_processed? && meals.any?

    meal_costs = {}

    meals.each do |meal|
      meal_cost = meal.calculate_cost_from_receipt(self)
      meal_costs[meal.id] = {
        meal: meal,
        cost: meal_cost,
        breakdown: meal.cost_breakdown_for_receipt(self)
      }
    end

    meal_costs
  end

  def total_meal_costs
    calculate_meal_costs.values.sum { |meal_data| meal_data[:cost] }
  end

  def unaccounted_cost
    receipt_total = receipt_total_from_items
    meal_total = total_meal_costs

    (receipt_total - meal_total).round(2)
  end

  def cost_coverage_percentage
    return 0.0 unless receipt_total_from_items > 0

    coverage = (total_meal_costs / receipt_total_from_items) * 100
    coverage.round(1)
  end

  def auto_match_all_ingredients!
    return false unless receipt_processed?

    success_count = 0

    receipt_items.each do |receipt_item|
      # Only try to match if not already matched
      next if receipt_item.ingredient_matches.any?

      match = Ingredient.auto_match_receipt_item!(receipt_item)
      success_count += 1 if match
    end

    success_count
  end

  def matching_summary
    return {} unless receipt_processed?

    total_items = receipt_items.count
    matched_items = receipt_items.joins(:ingredient_matches).distinct.count
    unmatched_items = total_items - matched_items

    {
      total_items: total_items,
      matched_items: matched_items,
      unmatched_items: unmatched_items,
      matching_percentage: total_items > 0 ? (matched_items.to_f / total_items * 100).round(1) : 0.0
    }
  end

  def bill_splitting_ready?
    receipt_processed? &&
    meals.any? &&
    meals.all? { |meal| meal.has_all_ingredients_matched?(self) }
  end

  def split_summary
    return {} unless bill_splitting_ready?

    meal_costs = calculate_meal_costs
    total_receipt = receipt_total_from_items

    {
      receipt_total: total_receipt,
      meal_costs: meal_costs,
      total_accounted: total_meal_costs,
      unaccounted: unaccounted_cost,
      coverage_percentage: cost_coverage_percentage
    }
  end
end