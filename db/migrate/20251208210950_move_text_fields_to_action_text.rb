class MoveTextFieldsToActionText < ActiveRecord::Migration[8.1]
  def up
    # Migrate existing blog post content to ActionText
    say_with_time "Migrating BlogPost content and excerpt to ActionText" do
      BlogPost.find_each do |post|
        if post.read_attribute(:content).present?
          post.content = post.read_attribute(:content)
          post.save(validate: false)
        end
        if post.read_attribute(:excerpt).present?
          post.excerpt = post.read_attribute(:excerpt)
          post.save(validate: false)
        end
      end
    end

    # Migrate existing project descriptions to ActionText
    say_with_time "Migrating Project descriptions to ActionText" do
      Project.find_each do |project|
        if project.read_attribute(:description).present?
          project.description = project.read_attribute(:description)
          project.save(validate: false)
        end
      end
    end

    # Migrate existing book reviews and notes to ActionText
    say_with_time "Migrating Book reviews and notes to ActionText" do
      Book.find_each do |book|
        if book.read_attribute(:review).present?
          book.review = book.read_attribute(:review)
          book.save(validate: false)
        end
        if book.read_attribute(:notes).present?
          book.notes = book.read_attribute(:notes)
          book.save(validate: false)
        end
      end
    end

    # Migrate existing gear item descriptions to ActionText
    say_with_time "Migrating GearItem descriptions to ActionText" do
      GearItem.find_each do |gear_item|
        if gear_item.read_attribute(:description).present?
          gear_item.description = gear_item.read_attribute(:description)
          gear_item.save(validate: false)
        end
      end
    end

    # Migrate existing sport activity descriptions to ActionText
    say_with_time "Migrating SportActivity descriptions to ActionText" do
      SportActivity.find_each do |activity|
        if activity.read_attribute(:description).present?
          activity.description = activity.read_attribute(:description)
          activity.save(validate: false)
        end
      end
    end

    # Remove old text columns after migration
    say_with_time "Removing old text columns" do
      remove_column :blog_posts, :content, :text if column_exists?(:blog_posts, :content)
      remove_column :blog_posts, :excerpt, :text if column_exists?(:blog_posts, :excerpt)
      remove_column :projects, :description, :text if column_exists?(:projects, :description)
      remove_column :books, :review, :text if column_exists?(:books, :review)
      remove_column :books, :notes, :text if column_exists?(:books, :notes)
      remove_column :gear_items, :description, :text if column_exists?(:gear_items, :description)
      remove_column :sport_activities, :description, :text if column_exists?(:sport_activities, :description)
    end
  end

  def down
    # Add columns back
    add_column :blog_posts, :content, :text unless column_exists?(:blog_posts, :content)
    add_column :blog_posts, :excerpt, :text unless column_exists?(:blog_posts, :excerpt)
    add_column :projects, :description, :text unless column_exists?(:projects, :description)
    add_column :books, :review, :text unless column_exists?(:books, :review)
    add_column :books, :notes, :text unless column_exists?(:books, :notes)
    add_column :gear_items, :description, :text unless column_exists?(:gear_items, :description)
    add_column :sport_activities, :description, :text unless column_exists?(:sport_activities, :description)

    # Migrate ActionText content back to columns
    BlogPost.find_each do |post|
      post.update_columns(
        content: post.content.present? ? post.content.to_plain_text : nil,
        excerpt: post.excerpt.present? ? post.excerpt.to_plain_text : nil
      )
    end

    Project.find_each do |project|
      project.update_column(:description, project.description.to_plain_text) if project.description.present?
    end

    Book.find_each do |book|
      book.update_columns(
        review: book.review.present? ? book.review.to_plain_text : nil,
        notes: book.notes.present? ? book.notes.to_plain_text : nil
      )
    end

    GearItem.find_each do |gear_item|
      gear_item.update_column(:description, gear_item.description.to_plain_text) if gear_item.description.present?
    end

    SportActivity.find_each do |activity|
      activity.update_column(:description, activity.description.to_plain_text) if activity.description.present?
    end
  end
end
