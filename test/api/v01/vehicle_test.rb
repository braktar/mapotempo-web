require 'test_helper'

class V01::VehiclesTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  set_fixture_class delayed_jobs: Delayed::Backend::ActiveRecord::Job

  def app
    Rails.application
  end

  setup do
    @vehicle = vehicles(:vehicle_one)
  end

  def api(part = nil, param = {})
    part = part ? '/' + part.to_s : ''
    "/api/0.1/vehicles#{part}.json?api_key=testkey1&" + param.collect{ |k, v| "#{k}=#{v}" }.join('&')
  end

  def api_admin(part = nil, param = {})
    part = part ? '/' + part.to_s : ''
    "/api/0.1/vehicles#{part}.json?api_key=adminkey&" + param.collect{ |k, v| "#{k}=#{v}" }.join('&')
  end

  test 'should return customer''s vehicles' do
    get api()
    assert last_response.ok?, last_response.body
    assert_equal @vehicle.customer.vehicles.size, JSON.parse(last_response.body).size
  end

  test 'should return customer''s vehicles by ids' do
    get api(nil, 'ids' => @vehicle.id)
    assert last_response.ok?, last_response.body
    assert_equal 1, JSON.parse(last_response.body).size
    assert_equal @vehicle.id, JSON.parse(last_response.body)[0]['id']
  end

  test 'should return a vehicle' do
    get api(@vehicle.id)
    assert last_response.ok?, last_response.body
    assert_equal @vehicle.name, JSON.parse(last_response.body)['name']
  end

  test 'should update a vehicle' do
    @vehicle.name = 'new name'
    put api(@vehicle.id), @vehicle.attributes
    assert last_response.ok?, last_response.body

    get api(@vehicle.id)
    assert last_response.ok?, last_response.body
    assert_equal @vehicle.name, JSON.parse(last_response.body)['name']
  end

  test 'should create and destroy a vehicle' do
    manage_vehicles_only_admin = Mapotempo::Application.config.manage_vehicles_only_admin
    [true, false].each { |v|
      Mapotempo::Application.config.manage_vehicles_only_admin = v
      new_name = 'new vehicle'
      post v ? api_admin : api, { ref: 'new', name: new_name, store_start_id: stores(:store_zero).id, store_stop_id: stores(:store_zero).id, customer_id: customers(:customer_one).id }
      assert last_response.created?, last_response.body

      get api(nil, {ids: 'ref:new'})
      assert last_response.ok?, last_response.body
      assert_equal new_name, JSON.parse(last_response.body)[0]['name']
      id = JSON.parse(last_response.body)[0]['id']

      assert_difference('Vehicle.count', -1) do
        delete v ? api_admin('ref:new') : api('ref:new')
        assert last_response.ok?, last_response.body
      end
    }
    Mapotempo::Application.config.manage_vehicles_only_admin = manage_vehicles_only_admin
  end

  test 'should create and destroy multiple vehicles' do
    manage_vehicles_only_admin = Mapotempo::Application.config.manage_vehicles_only_admin
    [true, false].each { |v|
      Mapotempo::Application.config.manage_vehicles_only_admin = v
      new_name = 'new vehicle 1'
      post v ? api_admin : api, { ref: 'new1', name: new_name, store_start_id: stores(:store_zero).id, store_stop_id: stores(:store_zero).id, customer_id: customers(:customer_one).id }
      assert last_response.created?, last_response.body
      new_name = 'new vehicle 2'
      post v ? api_admin : api, { ref: 'new2', name: new_name, store_start_id: stores(:store_zero).id, store_stop_id: stores(:store_zero).id, customer_id: customers(:customer_one).id }
      assert last_response.created?, last_response.body

      assert_difference('Vehicle.count', -2) do
        delete (v ? api_admin : api) + "&ids=ref:new1,ref:new2"
        assert last_response.ok?, last_response.body
      end
    }
    Mapotempo::Application.config.manage_vehicles_only_admin = manage_vehicles_only_admin
  end

  test 'should not destroy all vehicles' do
    manage_vehicles_only_admin = Mapotempo::Application.config.manage_vehicles_only_admin
    [true, false].each { |v|
      Mapotempo::Application.config.manage_vehicles_only_admin = v
      assert_no_difference('Vehicle.count') do
        delete (v ? api_admin : api) + "&ids=#{vehicles(:vehicle_one).id},#{vehicles(:vehicle_three).id}"
        assert last_response.server_error?, last_response.body
      end
    }
    Mapotempo::Application.config.manage_vehicles_only_admin = manage_vehicles_only_admin
  end
end
