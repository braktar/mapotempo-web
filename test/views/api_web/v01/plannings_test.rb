require 'test_helper'

class ApiWeb::V01::PlanningsTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  setup do
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

  test 'should return json for stop by index' do
    Bullet.enable = false # TODO: fix me by removing default scope  in planning
    customers(:customer_one).update(job_optimizer_id: nil)
    get "/api-web/0.1/routes/#{@planning.routes.first.id}/stops/by_index/1.json?api_key=testkey1"
    assert last_response.ok?, last_response.body
    json = JSON.parse(last_response.body)
    assert json['stop_id']
    assert !json['manage_organize']
  end
end
