class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name, limit: 32, null: false
      t.references :user, null: false
      t.integer :faction, null: false, default: 0
      t.integer :level, null: false, default: 0

      t.timestamps

      # Find players quickly by their names.
      t.index :name, unique: true

      # Find the player associated with a user account.
      t.index :user_id, unique: true
    end
  end
end
