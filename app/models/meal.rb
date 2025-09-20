class Meal < ApplicationRecord
  include Meal::Costable

  has_and_belongs_to_many :orders
  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients

  accepts_nested_attributes_for :meal_ingredients, allow_destroy: true, reject_if: proc { |attributes| attributes['ingredient_id'].blank? }

  validates :name, presence: true
  # validate :must_have_at_least_one_ingredient  # Temporarily disabled for testing

  private

  def must_have_at_least_one_ingredient
    if meal_ingredients.reject(&:marked_for_destruction?).empty?
      errors.add(:meal_ingredients, "must include at least one ingredient")
    end
  end
end
