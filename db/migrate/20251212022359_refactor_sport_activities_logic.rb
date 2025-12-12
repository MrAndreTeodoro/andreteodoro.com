class RefactorSportActivitiesLogic < ActiveRecord::Migration[8.1]
  def up
    # Remove is_upcoming_event column (logic will be date-based)
    remove_column :sport_activities, :is_upcoming_event, :boolean

    # Rename category 'result' to 'workout'
    SportActivity.where(category: "result").update_all(category: "workout")

    # Fill in null values before adding NOT NULL constraints
    SportActivity.where(value: nil).update_all(value: "TBD")
    SportActivity.where(unit: nil).update_all(unit: "time")
    SportActivity.where(date: nil).update_all(date: Date.today)

    # Make value, unit, and date required (NOT NULL)
    change_column_null :sport_activities, :value, false
    change_column_null :sport_activities, :unit, false
    change_column_null :sport_activities, :date, false
  end

  def down
    # Add back is_upcoming_event column
    add_column :sport_activities, :is_upcoming_event, :boolean, default: false

    # Rename category 'workout' back to 'result'
    SportActivity.where(category: "workout").update_all(category: "result")

    # Make value, unit, and date optional again
    change_column_null :sport_activities, :value, true
    change_column_null :sport_activities, :unit, true
    change_column_null :sport_activities, :date, true
  end
end
