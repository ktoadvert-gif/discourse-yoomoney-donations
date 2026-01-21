# name: discourse-yoomoney-donations
# about: Integrates YooMoney donations with dynamic progress bar
# version: 0.0.1
# authors: Antigravity
# url: https://github.com/your-repo/discourse-yoomoney-donations



enabled_site_setting :yoomoney_donations_enabled

# Load the engine first to define the module and constants
require_relative "lib/yoomoney_donations/engine"

after_initialize do
  # Extend the module with helper methods
  module ::YoomoneyDonations
    def self.current_amount
      Discourse.redis.get("yoomoney_current_amount").to_f
    end

    def self.add_amount(amount)
      Discourse.redis.incrbyfloat("yoomoney_current_amount", amount)
    end
  end
  
  # Ensure controller is loaded
  require_relative "app/controllers/yoomoney_donations/notifications_controller"

  # Define Engine Routes
  YoomoneyDonations::Engine.routes.draw do
    get "/status" => "notifications#status"
    post "/notifications" => "notifications#receive"
  end

  # Mount Engine
  Discourse::Application.routes.append do
    mount ::YoomoneyDonations::Engine, at: "/yoomoney"
  end

  # Allow public access to this MessageBus channel
  MessageBus.register_client_message_filter("/yoomoney/donations") do |message, user_ids, group_ids, site_id|
     true
  end

  Rails.logger.info "YooMoney Donations Plugin: Logic Loaded!"
end
