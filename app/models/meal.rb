class Meal < ApplicationRecord
  has_and_belongs_to_many :orders
  has_many :meal_ingredients, dependent: :destroy
  has_many :ingredients, through: :meal_ingredients
end
