module GaEvents
  class Engine < ::Rails::Engine
    config.app_middleware.use GaEvents::Middleware
  end
end
