class IngredientMatch < ApplicationRecord
  belongs_to :receipt_item
  belongs_to :ingredient
end
