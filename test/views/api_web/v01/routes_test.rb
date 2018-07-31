require 'test_helper'

class ApiWeb::V01::RoutesTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  setup do
    customers(:customer_one).update(enable_orders: false)
    @planning = plannings(:planning_one)
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

  test 'Api-web: should return json for planning' do
    Bullet.enable = false # TODO: fix me by removing default scope  in planning
    get "/api-web/0.1/plannings/#{@planning.id}/routes.json?api_key=testkey1"
    assert last_response.ok?, last_response.body
    json = JSON.parse(last_response.body)
    assert_equal @planning.routes.size, json['routes'].size
  end

  test 'Api-web: should return json for only one route' do
    Bullet.enable = false # TODO: fix me by removing default scope  in planning
    route = @planning.routes[0]
    get "/api-web/0.1/plannings/#{@planning.id}/routes.json?ids=#{route.id}&api_key=testkey1"
    assert last_response.ok?, last_response.body
    json = JSON.parse(last_response.body)
    assert_equal 1, json['routes'].size
  end
end
