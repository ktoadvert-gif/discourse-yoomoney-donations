# name: discourse-yoomoney-donations
# about: Integrates YooMoney donations with dynamic progress bar
# version: 0.3
# authors: Antigravity
# url: https://github.com/your-repo/discourse-yoomoney-donations

enabled_site_setting :yoomoney_donations_enabled

require 'digest/sha1'

module ::YoomoneyDonations
  PLUGIN_NAME = "discourse-yoomoney-donations".freeze

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace YoomoneyDonations
  end
end

after_initialize do
  require_dependency "application_controller"

  class ::YoomoneyDonations::NotificationsController < ::ApplicationController
    requires_plugin YoomoneyDonations::PLUGIN_NAME

    skip_before_action :check_xhr, :verify_authenticity_token, only: [:receive, :status], raise: false

    def status
      render json: {
        current: ::YoomoneyDonations.current_amount,
        goal: SiteSetting.yoomoney_donation_goal.to_f,
        wallet: SiteSetting.yoomoney_wallet_id
      }
    end

    def receive
      # Parameters for SHA-1 hash calculation:
      # notification_type&operation_id&amount&currency&datetime&sender&codepro&notification_secret&label
      
      # Ensure params are present to avoid nil errors
      secret = SiteSetting.yoomoney_notification_secret
      
      params_to_hash = [
        params[:notification_type],
        params[:operation_id],
        params[:amount],
        params[:currency],
        params[:datetime],
        params[:sender],
        params[:codepro],
        secret,
        params[:label]
      ].join('&')

      calculated_hash = Digest::SHA1.hexdigest(params_to_hash)

      if calculated_hash == params[:sha1_hash]
        amount_received = params[:withdraw_amount].to_f
        ::YoomoneyDonations.add_amount(amount_received)
        render json: { status: "ok" }, status: 200
      else
        Rails.logger.warn("Yoomoney hash mismatch. Calculated: #{calculated_hash}, Received: #{params[:sha1_hash]}")
        render json: { status: "error", message: "invalid signature" }, status: 403
      end
    end
  end

  module ::YoomoneyDonations
    def self.current_amount
      Discourse.redis.get("yoomoney_current_amount").to_f
    end

    def self.add_amount(amount)
      Discourse.redis.incrbyfloat("yoomoney_current_amount", amount)
    end
  end

  YoomoneyDonations::Engine.routes.draw do
    get "/status" => "notifications#status"
    post "/notifications" => "notifications#receive"
  end

  Discourse::Application.routes.append do
    mount ::YoomoneyDonations::Engine, at: "/yoomoney"
  end
end
