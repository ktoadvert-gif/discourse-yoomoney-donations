# name: discourse-yoomoney-donations
# about: Integrates YooMoney donations with dynamic progress bar
# version: 0.0.1
# authors: Antigravity
# url: https://github.com/your-repo/discourse-yoomoney-donations

enabled_site_setting :yoomoney_donations_enabled

after_initialize do
  module ::YoomoneyDonations
    PLUGIN_NAME = "discourse-yoomoney-donations"
  end

  require_relative "lib/yoomoney_donations/engine"

  Rails.logger.info "YooMoney Donations Plugin: Engine Loaded Successfully!"
end
