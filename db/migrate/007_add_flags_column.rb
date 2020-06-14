class AddFlagsColumn < ActiveRecord::Migration
  def self.up
    add_column :resources, :flags, :string
  end

  def self.down
    remove_column :resources, :flags
  end

end
