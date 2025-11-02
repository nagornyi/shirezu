class CreateProfilesTable < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column "time_zone", :string, :default => 'UTC'
    end
  end

  def self.down
    drop_table :profiles
  end
end

