class RemoveSelectedFromReceiptItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :receipt_items, :selected, :boolean
  end
end
