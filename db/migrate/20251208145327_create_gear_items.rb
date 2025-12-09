class CreateGearItems < ActiveRecord::Migration[8.1]
  def change
    create_table :gear_items do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.string :affiliate_link
      t.string :image_url
      t.decimal :price, precision: 10, scale: 2
      t.boolean :featured, default: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :gear_items, :category
    add_index :gear_items, :featured
    add_index :gear_items, :position
  end
end
