class Stripe::OauthController < ApplicationController

  class Stripe::OauthController::UnexpectedErrorInResponse; end

  before_filter :set_owner

  def setup
    @owner.create_stripe_account
    redirect_to @owner.stripe_account.auth_uri
    session[:user] = @owner.key
  end

  def redirect
    session[:user] = nil
    if (error = params[:error]).present?
      if error == 'access_denied'
        # user cancelled the auth
        flash[:info] = "We need you to sign up to Stripe for this to work..."
        redirect_to root_url
      else
        raise UnexpectedErrorInResponse.new("#{error} - #{params[:error_description]}")
      end
    else
      @stripe_account = @owner.stripe_account
      @stripe_account.auth_token = params[:code]
      @stripe_account.save!
      @owner.stripe_account.get_access_token
      redirect_to :action => :pending, :id => @owner_id
    end
  end

  def pending
    if @owner.stripe_account.nil?
      redirect_to :setup, :id => @owner_id
    elsif @owner.stripe_account.enabled?
      redirect_to :action => :done, :id => @owner_id
    end
  end

  def done
  end

  def cancel
    @owner.stripe_account.destroy
  end

  private

  def owner_id
    @owner_id ||= params[:id] || session[:user]
  end

  def set_owner
    @owner = Owner.find_by_key(owner_id)
  end
end
