class Stripe::OauthController < ApplicationController

  class Stripe::OauthController::UnexpectedErrorInResponse; end

  before_filter :set_owner

  def setup
    @owner = Owner.find(params[:id])
    @owner.create_stripe_account
    redirect_to @owner.stripe_account.auth_uri
    session[:user] = @owner.key
  end

  def redirect
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
      redirect_to :pending
    end
  end

  private

  def owner_id
    @owner_id ||= params[:id] || session[:user]
  end

  def set_owner
    @owner = Owner.find(owner_id)
  end
end
