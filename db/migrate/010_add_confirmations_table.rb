class AddConfirmationsTable < ActiveRecord::Migration
  def self.up
    create_table :confirmations do |t|
      t.column "email", :string
      t.column "code", :text
      t.references :company
      t.references :project
      t.references :role
    end
  end

  def self.down
    drop_table :confirmations
  end
end
