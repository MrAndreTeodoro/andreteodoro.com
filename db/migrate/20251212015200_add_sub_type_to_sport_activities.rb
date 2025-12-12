class AddSubTypeToSportActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :sport_activities, :sub_type, :string
    add_index :sport_activities, :sub_type
  end
end
