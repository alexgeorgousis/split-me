class ChangeReceiptItemPriceDefaultToZero < ActiveRecord::Migration[8.0]
  def change
    change_column_default :receipt_items, :price, from: nil, to: 0
  end
end
