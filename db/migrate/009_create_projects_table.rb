class CreateProjectsTable < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
		t.column "name", :string
		t.column "description", :text
		t.references :company
    end
  end

  def self.down
    drop_table :projects
  end
end

