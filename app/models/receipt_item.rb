class ReceiptItem < ApplicationRecord
  belongs_to :receipt
  has_many :ingredient_matches, dependent: :destroy
  has_many :ingredients, through: :ingredient_matches
end
