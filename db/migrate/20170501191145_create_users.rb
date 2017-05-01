class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.text :user_id
      t.string :city

      t.timestamps
    end
  end
end
