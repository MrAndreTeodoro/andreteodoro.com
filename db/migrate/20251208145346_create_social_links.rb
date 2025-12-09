class CreateSocialLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :social_links do |t|
      t.string :platform, null: false
      t.string :url, null: false
      t.integer :follower_count
      t.string :username
      t.boolean :display_in_header, default: true

      t.timestamps
    end

    add_index :social_links, :platform
  end
end
