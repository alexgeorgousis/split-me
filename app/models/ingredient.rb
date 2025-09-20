class Ingredient < ApplicationRecord
  include Ingredient::Matchable

  has_many :meal_ingredients, dependent: :destroy
  has_many :meals, through: :meal_ingredients
  has_many :ingredient_matches, dependent: :destroy
  has_many :receipt_items, through: :ingredient_matches
end
