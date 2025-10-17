class ReceiptItem < ApplicationRecord
  belongs_to :receipt

  enum :split_mode, { mine: 0, shared: 1, undecided: 2 }

  def my_share_amount
    case split_mode
    when "mine"
      price
    when "shared"
      (price / 2.0).round(2)
    when "undecided"
      0.0
    else
      0.0
    end
  end

  def their_share_amount
    case split_mode
    when "mine"
      0.0
    when "shared"
      (price / 2.0).round(2)
    when "undecided"
      price
    else
      0.0
    end
  end

  def favourite?
    Favourite.owned_by_user.exists? name: name
  end
end
