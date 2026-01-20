module YoomoneyDonations
  class NotificationsController < ::ApplicationController
    requires_plugin YoomoneyDonations::PLUGIN_NAME

    skip_before_action :check_xhr, :verify_authenticity_token, only: [:status], raise: false

    def status
      render json: { status: "ok", message: "YooMoney Plugin is alive!" }
    end
  end
end
