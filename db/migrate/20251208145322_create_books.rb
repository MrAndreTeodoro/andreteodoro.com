class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :cover_url
      t.string :affiliate_link
      t.text :review
      t.text :notes
      t.integer :rating
      t.date :read_date
      t.string :isbn
      t.string :category
      t.boolean :featured, default: false

      t.timestamps
    end

    add_index :books, :rating
    add_index :books, :read_date
    add_index :books, :category
    add_index :books, :featured
  end
end
