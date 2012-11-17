require 'bcrypt'

class Owner < ActiveRecord::Base
  include BCrypt

  validates :name, :email, :password, :presence => true

  before_create :generate_key

  has_one :stripe_account, :dependent => :destroy

  attr_accessible :name, :email, :password, :company

  # users.password_hash in the database is a :string

  def pass
    @pass ||= Password.new(self.password)
  end

  def pass=(new_password)
    @pass = Password.create(new_password)
    self.password = @pass
  end

  private

  def generate_key
    self.key = SecureRandom.base64(30)
  end
end
