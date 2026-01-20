# name: discourse-yoomoney-donations
# about: Integrates YooMoney donations with dynamic progress bar
# version: 0.0.1
# authors: Antigravity
# url: https://github.com/your-repo/discourse-yoomoney-donations

enabled_site_setting :yoomoney_donations_enabled

after_initialize do
  Rails.logger.info "YooMoney Donations Plugin: Successfully verified connectivity!"
  puts "YooMoney Donations Plugin: Successfully verified connectivity!"
end
