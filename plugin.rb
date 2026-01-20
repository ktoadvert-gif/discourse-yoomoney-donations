# name: discourse-yoomoney-donations
# about: A minimal example plugin to verify connectivity
# version: 0.0.1
# authors: Antigravity
# url: https://github.com/your-repo/discourse-yoomoney-donations

after_initialize do
  Rails.logger.info "YooMoney Donations Plugin: Successfully verified connectivity!"
  puts "YooMoney Donations Plugin: Successfully verified connectivity!"
end
