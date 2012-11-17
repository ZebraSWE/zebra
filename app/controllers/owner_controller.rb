class OwnerController < ApplicationController
  def index
    @owners = Owner.all
  end

  def show
    @owner = Owner.find(:params['id'])
  end

  def destroy
    @owner = Owner.find(:params['id'])
    @owner.destroy!
  end
end
