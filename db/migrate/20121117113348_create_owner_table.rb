class CreateOwnerTable < ActiveRecord::Migration
  def up
    create_table  :owners do |t|
      t.string    :name
      t.string    :email
      t.string    :company
      t.string    :password

      t.string    :key,     :limit => 40

      t.timestamps
    end
    add_index :owners, :key
  end

  def down
    drop_table :owners
  end
end
