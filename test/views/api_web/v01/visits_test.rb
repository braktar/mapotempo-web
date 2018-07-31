require 'test_helper'

class ApiWeb::V01::VisitsTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  setup do
    @customer = customers(:customer_one)
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

  test 'Api-web: should return json for visit' do
    get "/api-web/0.1/visits/#{visits(:visit_one).id}.json?api_key=testkey1"
    assert last_response.ok?, last_response.body
    json = JSON.parse(last_response.body)
    assert json['visit_id']
    assert !json['manage_organize']
  end
end
