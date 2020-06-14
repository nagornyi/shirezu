class AddNotificationColumn < ActiveRecord::Migration
  def self.up
    add_column :resources, :notification, :string
  end

  def self.down
    remove_column :resources, :notification
  end

end
