module ::YoomoneyDonations
  PLUGIN_NAME = "discourse-yoomoney-donations"

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace YoomoneyDonations
  end
end
