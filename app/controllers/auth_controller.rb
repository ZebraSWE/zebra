class AuthController < ApplicationController
  def login
  end

  def signup
    name = params[:owner][:name]
    email = params[:owner][:email]
    insecure_password = params[:owner][:password]
    secure_password = BCrypt::Password.create(insecure_password)
    owner = Owner.new
    owner.name = name
    owner.email = email
    owner.password = secure_password
    owner.save
  end
end
