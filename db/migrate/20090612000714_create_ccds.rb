class CreateCcds < ActiveRecord::Migration
  def self.up
    create_table :ccds do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :ccds
  end
end
