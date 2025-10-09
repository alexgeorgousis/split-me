module Order::Splittable
  extend ActiveSupport::Concern

  def my_receipt_total
    receipt.receipt_items.where(selected: true).sum(&:my_share_amount)
  end

  def their_receipt_total
    # TODO: There should be a receipt.total method to do this
    total = receipt.receipt_items.sum(:price)
    total - my_receipt_total
  end
end
