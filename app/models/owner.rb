class Owner < ActiveRecord::Base
  validates :name, :email, :password, :key, :presence => true

  has_one :stripe_account, :dependent => :destroy
end
