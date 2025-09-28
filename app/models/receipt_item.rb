class ReceiptItem < ApplicationRecord
  belongs_to :receipt
  has_many :ingredient_matches, dependent: :destroy
  has_many :ingredients, through: :ingredient_matches

  enum :split_mode, { mine: 0, shared: 1, theirs: 2 }

  def my_share_amount
    case split_mode
    when "mine"
      price
    when "shared"
      (price / 2.0).round(2)
    when "theirs"
      0.0
    end
  end

  def their_share_amount
    case split_mode
    when "mine"
      0.0
    when "shared"
      (price / 2.0).round(2)
    when "theirs"
      price
    end
  end
end
