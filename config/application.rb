require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Usasearch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Rails 4 way of “eager_load with autoload fallback. Note need to revisit better
    # solution. See https://collectiveidea.com/blog/archives/2016/07/22/solutions-to-potential-upgrade-problems-in-rails-5
    config.enable_dependency_loading = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir[config.root.join('lib', '**/').to_s]
    config.autoload_paths += Dir[config.root.join('app/models', '**/').to_s]

    config.middleware.use RejectInvalidRequestUri
    config.middleware.use DowncaseRoute
    config.middleware.use AdjustClientIp
    config.middleware.use FilteredJSONP

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running, except during DB migrations.
    unless File.basename($0) == "rake" && ARGV.include?("db:migrate")
      config.active_record.observers = :sayt_filter_observer, :misspelling_observer, :indexed_document_observer,
        :affiliate_observer, :navigable_observer, :searchable_observer, :rss_feed_url_observer,
        :i14y_drawer_observer, :routed_query_keyword_observer, :watcher_observer
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.generators do |g|
      g.test_framework :rspec
    end

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.active_record.schema_format = :sql

    config.i18n.enforce_available_locales = false

    config.ssl_options[:redirect] =
      { exclude: ->(request) { request.path == '/healthcheck' } }

    config.active_job.queue_adapter = :resque

    ### Rails 5.0 config flags
    # Require `belongs_to` associations by default. Versions before Rails 5.0 had false.
    config.active_record.belongs_to_required_by_default = false
    ### End Rails 5.0 config flags

    # Turn on the classic autoloader, because zeitwerk blows
    # up. SRCH-2286 is the ticket to move i14y to zeitwerk.
    config.autoloader = :classic
  end
end
