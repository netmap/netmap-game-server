class CreatePlayerStats < ActiveRecord::Migration
  def change
    create_table :player_stats do |t|
      t.references :player, null: false
      t.integer :xp, null: false
      t.integer :mana, null: false

      # NOTE(pwnall): this table will update very often, so we don't put
      #               timestamps on it

      t.index :player_id, unique: true
    end
  end
end
