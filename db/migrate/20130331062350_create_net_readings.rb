class CreateNetReadings < ActiveRecord::Migration
  def change
    create_table :net_readings do |t|
      t.references :player, index: true
      t.string :digest, null: false, limit: 64
      t.text :json_data, null: false, limit: 64.kilobytes

      t.datetime :created_at
    end

    add_index :net_readings, :digest, unique: true
  end
end
