# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../../app", __FILE__)

ENV["DISCORD_CLIENT_ID"] = "12345678901234567"
ENV["DISCORD_TOKEN"] = "t0k3nt0k3nt0k3nt0k3nt0k3n.1234hrx0rz1234token"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

def load_fixture(fixture_name)
  fixture_path = "#{File.dirname(__FILE__)}/fixtures"
  File.read(File.join(fixture_path, "#{fixture_name}.json"))
end

def load_fixture_obj(fixture_name)
  JSON.parse(load_fixture(fixture_name))
end

def stub_tfl_response(path, fixture, status = 200)
  stub_request(:get, "https://api.tfl.gov.uk#{path}").
    to_return(status: status, body: load_fixture(fixture), headers: {
      "Content-Type": "application/json; charset=utf-8"
    })
end

def stub_tfl_not_found(path)
  stub_request(:get, "https://api.tfl.gov.uk#{path}").to_return(status: 404)
end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

require "tflbot"
