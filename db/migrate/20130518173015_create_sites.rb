class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.point :location, geographic: true, null: false
      t.references :site_layout, null: false
      t.references :author, null: false

      t.timestamps

      # A player's sites.
      t.index :author_id, unique: false

      # The sites around a location.
      t.index :location, spatial: true
    end
  end
end
