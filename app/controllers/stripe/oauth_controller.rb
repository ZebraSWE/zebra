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
      else
        # unexpected error
        raise UnexpectedErrorInResponse.new("#{error} - #{params[:error_description]}")
      end
    else
      # Normal response
      # fire off a job
      @owner.stripe_account.get_access_token
      # redirect to pending
      redirect_to :pending, :id => @owner_id
    end
  end

  def pending
    if @owner.stripe_account.nil?
      redirect_to :setup, :id => @owner_id
    elsif @owner.stripe_account.enabled?
      redirect_to :done, :id => @owner_id
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
