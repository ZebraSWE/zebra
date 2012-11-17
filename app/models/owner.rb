class Owner < ActiveRecord::Base
  validates :name, :email, :password, :presence => true

  before_create :generate_key

  has_one :stripe_account, :dependent => :destroy

  private

  def generate_key
    key = SecureRandom.base64(30)
  end
end
