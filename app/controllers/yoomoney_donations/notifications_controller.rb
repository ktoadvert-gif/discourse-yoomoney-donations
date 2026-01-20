module YoomoneyDonations
  class NotificationsController < ::ApplicationController
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
      # Parameters for SHA-1 hash calculation
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
end
