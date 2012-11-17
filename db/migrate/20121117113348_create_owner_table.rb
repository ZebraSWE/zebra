class CreateOwnerTable < ActiveRecord::Migration
  def up
    create_table  :owner do |t|
      t.string    :name
      t.string    :email
      t.string    :company
      t.string    :password

      t.string    :key,     :limit => 40

      t.timestamps
    end
    add_index :owner, :key
  end

  def down
    drop_table :owner
  end
end
