require 'test_helper'

class ApiWeb::V01::DestinationsTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  setup do
    @customer = customers(:customer_one)
    @customer.update(enable_orders: false)
  end

  # TODO
  # Bullet not taken into account in controller, need to be in views
  def around
    begin
      Bullet.enable = true
      yield
    ensure
      Bullet.enable = false
    end
  end

  test 'Api-web: should return json for destinations' do
    [:get, :post].each do |method|
      send method, "/api-web/0.1/destinations.json?api_key=testkey1"
      assert last_response.ok?, last_response.body
      json = JSON.parse(last_response.body)
      assert_equal @customer.destinations.size, json['destinations'].size
    end
  end

  test 'Api-web: should return json for some destinations' do
    [:get, :post].each do |method|
      send method, "/api-web/0.1/destinations.json?api_key=testkey1", {ids: [destinations(:destination_one).id, destinations(:destination_two).id].join(',')}
      assert last_response.ok?, last_response.body
      json = JSON.parse(last_response.body)
      assert_equal 2, json['destinations'].size
    end
  end
end
