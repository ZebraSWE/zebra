class StripeAccount < ActiveRecord::Base

  OAUTH_URL = "https://connect.stripe.com/oauth/authorize"
  #?response_type=code&client_id=#{STRIPE_CLIENT_ID}"

  belongs_to :owner
  validates_presence_of :owner
  validates_uniqueness_of :owner_id
  validates_uniqueness_of :state, :is => 40, :allow_nil => true

  def auth_uri
    generate_state
    params = {
      :response_type => 'code',
      :client_id => STRIPE_CLIENT_ID,
      :state => self.state
    }
    OAUTH_URL + '?' + params.to_query
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

end
