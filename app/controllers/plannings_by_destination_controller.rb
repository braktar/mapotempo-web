# Copyright © Mapotempo, 2013-2018
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
class PlanningsByDestinationController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :destination
  before_action :set, only: %i[show]

  def show; end

  private

  def set
    @customer = current_user.customer
    @stop_visits = @destination.visits.map(&:stop_visits).flatten.sort_by{ |st| st.route.planning_id }
    # [planning_id => [vehicle_id => route_id]]
    @routes_by_vehicles = {}
    @customer.plannings.each do |planning|
      @routes_by_vehicles[planning.id] = {}
      planning.routes.each{ |route|
        vehicle_id = route.vehicle_usage ? route.vehicle_usage.vehicle_id : nil
        @routes_by_vehicles[planning.id][vehicle_id] = route.id
      }
    end
  end
end
