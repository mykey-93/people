if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'spork'
require 'sucker_punch/testing/inline'
require 'capybara/rspec'
require 'rack_session_access/capybara'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.include Mongoid::Matchers, type: :model
    config.include Devise::TestHelpers, type: :controller
    config.include Helpers::JSONResponse, type: :controller
    I18n.enforce_available_locales = false
    config.include Capybara::DSL

    config.before(:suite) do
      DatabaseCleaner[:mongoid].strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.infer_base_class_for_anonymous_controllers = false
  end
end

Spork.each_run do
  FactoryGirl.reload
end
