class AddPublishableKeyToStripeAccount < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :publishable_key, :string
  end
end
