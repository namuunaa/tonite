class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.text :device_id
      t.string :city

      t.timestamps
    end
  end
end
