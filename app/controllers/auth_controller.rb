class AuthController < ApplicationController
  def login
  end

  def signup
    @owner = Owner.new
  end
end
