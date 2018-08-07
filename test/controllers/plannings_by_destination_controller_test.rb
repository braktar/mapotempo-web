require 'test_helper'

require 'rexml/document'
include REXML

class PlanningsByDestinationControllerTest < ActionController::TestCase

  setup do
    @request.env['reseller'] = resellers(:reseller_one)
    @destination = destinations(:destination_one)
    @destination.visits.create(tags: [tags(:tag_one)])
    sign_in users(:user_one)
  end

  test 'user can only view plannings from its customer' do
    ability = Ability.new(users(:user_one))
    assert ability.can? :show, @destination
    ability = Ability.new(users(:user_three))
    assert ability.cannot? :show, @destination

    get :show, destination_id: destinations(:destination_four).id
    assert_response :redirect
  end

  test 'should show plannings by destination' do
    begin
      $stop_ids = @destination.visits.flat_map(&:stop_visits).map(&:id)
      Stop.class_eval do
        after_initialize :after_init
        def after_init
          raise unless $stop_ids.include? self.id
        end
      end
      get :show, destination_id: @destination.id
      assert_response :success
      assert_valid response
      assert_equal 2, assigns(:stop_visits).size
      assert_equal 2, assigns(:routes_by_vehicles).size
      assert_equal 3, assigns(:routes_by_vehicles).flat_map{ |_k, v| v.keys }.uniq.size
    ensure
      Stop.class_eval do
        def after_init
        end
      end
    end
  end
end
