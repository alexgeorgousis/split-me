class AddEmailVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :verified, :boolean, default: false, null: false
    add_column :users, :verification_sent_at, :datetime

    User.update_all(verified: true)
  end
end
