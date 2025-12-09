class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.string :url
      t.string :logo_url
      t.string :project_type, null: false
      t.boolean :featured, default: false
      t.text :tech_stack
      t.string :status, default: 'active'
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :projects, :project_type
    add_index :projects, :featured
    add_index :projects, :position
  end
end
