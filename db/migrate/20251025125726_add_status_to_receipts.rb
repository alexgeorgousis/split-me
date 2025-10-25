class AddStatusToReceipts < ActiveRecord::Migration[8.1]
  def change
    add_column :receipts, :status, :integer

    reversible do |dir|
      dir.up do
        Receipt.reset_column_information
        Receipt.find_each do |receipt|
          status = receipt.receipt_items.any? ? 2 : 0
          receipt.update_column(:status, status)
        end
      end
    end

    change_column_null :receipts, :status, false
  end
end
