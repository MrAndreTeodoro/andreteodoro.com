class AddIsUpcomingEventToSportActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :sport_activities, :is_upcoming_event, :boolean, default: false, null: false
    add_index :sport_activities, :is_upcoming_event
  end
end
