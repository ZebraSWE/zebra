class OwnersController < ApplicationController
  def index
    @owners = Owner.all
  end

  def show
    @owner = Owner.find(params['id'])
  end

  def create
    @owner = Owner.new(params[:owner])
    @owner.pass = params[:owner][:password]
    unless @owner.save!
      Rails.logger.error "Failed to create user"
      flash[:errors] = "Could not create user"
    end
    redirect_to root_path
  end

  def login
    email = params[:owner][:email]
    password = params[:owner][:password]
    if @owner = Owner.find_by_email(email) and @owner.pass == password
      session[:logged_in] = true
    else
      redirect_to root_url
    end
  end
end
