class AddDemoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :demo, :boolean, default: false
  end
end
