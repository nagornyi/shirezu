class CreateCompaniesTable < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.column "name", :string
      t.column "description", :text
    end
  end

  def self.down
    drop_table :companies
  end
end

