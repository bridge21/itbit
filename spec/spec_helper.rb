require 'bundler/setup'
Bundler.setup

require 'itbit'
require 'webmock/rspec'
require 'shoulda/matchers'
require 'timecop'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.include RequestStubs

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = true
    mocks.syntax = [:expect, :should]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should]
  end
  
  config.after(:each) do
    Timecop.return
  end

  config.before :each do
    Itbit.client_key = 'the-client-key'
    Itbit.secret = 'the-secret'
    Itbit.user_id = 'the-user-id'
    Itbit.default_wallet_id = 'wallet-000'
  end

  config.order = "random"
end

