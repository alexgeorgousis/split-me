class RenameOrdersToSplits < ActiveRecord::Migration[8.0]
  def change
    rename_table :orders, :splits
    rename_column :receipts, :order_id, :split_id
  end
end
