class CreateStripeAccountTable < ActiveRecord::Migration
  def up
    create_table :stripe_accounts do |t|
      t.string        :auth_token
      t.string        :access_token
      t.string        :refresh_token
      t.string        :state
      t.references    :owner,         :null => false
    end

    add_index :stripe_accounts, :owner_id, {:unique => true}
    add_foreign_key :stripe_accounts, :owners
  end

  def down
    drop_table :stripe
  end
end
