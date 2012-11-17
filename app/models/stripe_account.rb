class StripeAccount < ActiveRecord::Base
  class StripeAccount::ErrorFetchingAccessToken; end

  AUTH_URL = "https://connect.stripe.com/oauth/authorize"
  ACCESS_URL = "https://connect.stripe.com/oauth/token"

  belongs_to :owner
  validates_presence_of :owner
  validates_uniqueness_of :owner_id
  validates_uniqueness_of :state, :is => 40, :allow_nil => true

  def self.do_get_access_token(auth_token)
    response = HTTParty.post(access_uri(auth_token), :headers => {'Authorization' => "Bearer #{STRIPE_SECRET_KEY}"})
    payload = JSON.parse response.body
    Rails.logger.info "HJM #{response}"
    if (error = payload[:error]).present?
      raise ErrorFetchingAccessToken.new("#{error} - #{payload[:error_description]}")
    else
      self.access_token = payload[:access_token]
      self.refresh_token = payload[:refresh_token]
      self.publishable_key = payload[:publishable_key]
      self.save!
    end
  end

  def self.access_uri(auth_token)
    params = {
      :code => auth_token,
      :grant_type => 'authorization_code'
    }
    ACCESS_URL + '?' + params.to_query
  end

  def get_access_token
    if Rails.env.test?
      do_get_access_token(self.auth_token)
    else
      StripeOauthJob.new.enqueue(self.auth_token)
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
