class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt
      t.text :content
      t.datetime :published_at
      t.boolean :viral, default: false
      t.boolean :featured, default: false
      t.integer :views_count, default: 0
      t.integer :reading_time

      t.timestamps
    end

    add_index :blog_posts, :slug, unique: true
    add_index :blog_posts, :published_at
    add_index :blog_posts, :viral
  end
end
