class StripeAccount < ActiveRecord::Base
  class StripeAccount::ErrorFetchingAccessToken; end

  AUTH_URL = "https://connect.stripe.com/oauth/authorize"
  ACCESS_URL = "https://connect.stripe.com/oauth/token"

  belongs_to :owner
  validates_presence_of :owner
  validates_uniqueness_of :owner_id
  validates_uniqueness_of :state, :is => 40, :allow_nil => true

  def do_get_access_token
    response = HTTParty.post(access_uri, :headers => {'Authorization' => "Bearer #{STRIPE_SECRET_KEY}"})
    payload = JSON.parse response.body
    if (error = payload[:error]).present?
      raise ErrorFetchingAccessToken.new("#{error} - #{payload[:error_description]}")
    else
      self.access_token = payload['access_token']
      self.refresh_token = payload['refresh_token']
      self.publishable_key = payload['stripe_publishable_key']
      self.save!
    end
  end

  def access_uri
    params = {
      :code => self.auth_token,
      :grant_type => 'authorization_code'
    }
    ACCESS_URL + '?' + params.to_query
  end

  def get_access_token
    if Rails.env.test?
      do_get_access_token(self.auth_token)
    else
      Delayed::Job.enqueue(StripeOauthJob.new(self.id))
    end
  end

  def pending?
    self.auth_token.present? && self.access_token.blank?
  end

  def enabled?
    self.access_token.present?
  end

  def generate_state
    if self.state.blank?
      self.state = SecureRandom.base64(30)
      self.save!
    end
  end

  def valid_state?(state)
    self.state == state
  end

  def auth_uri
    generate_state
    params = {
      :response_type => 'code',
      :client_id => STRIPE_CLIENT_ID,
      :state => self.state
    }
    AUTH_URL + '?' + params.to_query
  end
end
