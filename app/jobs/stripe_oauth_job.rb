class StripeOauthJob < Struct.new(:stripe_account_id)
  def perform
    logger = Delayed::Worker.logger

    begin
      stripe_account = StripeAccount.find(stripe_account_id)
    rescue ActiveRecord::RecordNotFound => ex
      logger.error("Failed to find stripe account with id #{stripe_account_id}"
    end

    logger.info "#{Time.new.strftime("%b %d %Y %H:%M:%S")}: [JOB] Retrieving OAuth access token for #{stripe_account.owner.name}."

    runtime = Benchmark.realtime do
      stripe_account.do_fetch_token(logger)
    end
  end

  def failure
    logger = Delayed::Worker.logger
    stripe_account = StripeAccount.find(stripe_account_id)
    logger.error "#{Time.new.strftime("%b %d %Y %H:%M:%S")}: [JOB] Failed to connect to Stripe too many times. No longer retrying to fetch access token for #{stripe_account.owner.name}."
    stripe_account.destroy
  end
end
