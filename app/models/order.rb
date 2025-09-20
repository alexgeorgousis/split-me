class Order < ApplicationRecord
  has_and_belongs_to_many :meals
  has_one_attached :receipt
end
