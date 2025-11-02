class AddResourcesTable < ActiveRecord::Migration
  def self.up
	create_table :resources do |t|
	t.column "name", :string
	t.column "description", :text
	t.references :user
	t.column "occupied_at", :datetime
	t.timestamps
	t.references :project
	t.references :company
    end
  end

  def self.down
    drop_table :resources
  end
end
