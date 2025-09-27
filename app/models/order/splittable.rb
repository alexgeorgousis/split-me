module Order::Splittable
  extend ActiveSupport::Concern

  def calculate_meal_costs
    return {} unless receipt.processed? && meals.any?

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
    receipt_total = selected_receipt_total
    meal_total = total_meal_costs

    (receipt_total - meal_total).round(2)
  end

  def cost_coverage_percentage
    return 0.0 unless selected_receipt_total > 0

    coverage = (total_meal_costs / selected_receipt_total) * 100
    coverage.round(1)
  end

  def auto_match_all_ingredients!
    return false unless receipt.processed?

    success_count = 0

    receipt_items.each do |receipt_item|
      next if receipt_item.ingredient_matches.any?

      match = Ingredient.auto_match_receipt_item!(receipt_item)
      success_count += 1 if match
    end

    success_count
  end

  def matching_summary
    return {} unless receipt.processed?

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
    receipt.processed? && meals.any?
  end

  def split_summary
    return {} unless bill_splitting_ready?

    meal_costs = calculate_meal_costs
    total_receipt = selected_receipt_total

    {
      receipt_total: total_receipt,
      meal_costs: meal_costs,
      total_accounted: total_meal_costs,
      unaccounted: unaccounted_cost,
      coverage_percentage: cost_coverage_percentage
    }
  end

  def selected_receipt_total
    receipt_items.where(selected: true).sum(:price)
  end
end
