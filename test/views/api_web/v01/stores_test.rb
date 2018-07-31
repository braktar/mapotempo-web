require 'test_helper'

class ApiWeb::V01::StoresTest < ActiveSupport::TestCase
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

  test 'Api-web: should return json for stores' do
    [:get, :post].each do |method|
      send method, "/api-web/0.1/stores.json?api_key=testkey1"
      assert last_response.ok?, last_response.body
      json = JSON.parse(last_response.body)
      assert_equal @customer.stores.size, json['stores'].size
    end
  end

  test 'Api-web: should return json for some stores' do
    [:get, :post].each do |method|
      send method, "/api-web/0.1/stores.json?api_key=testkey1", {ids: stores(:store_one).id.to_s + ',' + stores(:store_one_bis).id.to_s}
      assert last_response.ok?, last_response.body
      json = JSON.parse(last_response.body)
      assert_equal 2, json['stores'].size
    end
  end
end
