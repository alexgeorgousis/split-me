class CreateMeals < ActiveRecord::Migration[8.0]
  def change
    create_table :meals do |t|
      t.string :name

      t.timestamps
    end
  end
end
