# name: discourse-yoomoney-donations
# about: Integrates YooMoney donations with dynamic progress bar
# version: 0.0.1
# authors: Antigravity
# url: https://github.com/your-repo/discourse-yoomoney-donations

enabled_site_setting :yoomoney_donations_enabled

  module ::YoomoneyDonations
    PLUGIN_NAME = "discourse-yoomoney-donations"

    def self.current_amount
      Discourse.redis.get("yoomoney_current_amount").to_f
    end

    def self.add_amount(amount)
      Discourse.redis.incrbyfloat("yoomoney_current_amount", amount)
    end
  end

  require_relative "lib/yoomoney_donations/engine"
  
  require_relative "app/controllers/yoomoney_donations/notifications_controller"

  YoomoneyDonations::Engine.routes.draw do
    get "/status" => "notifications#status"
    post "/notifications" => "notifications#receive"
  end

  Discourse::Application.routes.append do
    mount ::YoomoneyDonations::Engine, at: "/yoomoney"
  end

  Rails.logger.info "YooMoney Donations Plugin: Logic Loaded!"
end
