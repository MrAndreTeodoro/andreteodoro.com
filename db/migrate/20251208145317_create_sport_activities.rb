class CreateSportActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :sport_activities do |t|
      t.string :sport_type, null: false
      t.string :category, null: false
      t.string :title, null: false
      t.text :description
      t.string :value
      t.string :unit
      t.date :date
      t.string :event_name
      t.string :location
      t.string :result_url
      t.boolean :personal_record, default: false

      t.timestamps
    end

    add_index :sport_activities, :sport_type
    add_index :sport_activities, :category
    add_index :sport_activities, :date
    add_index :sport_activities, :personal_record
  end
end
