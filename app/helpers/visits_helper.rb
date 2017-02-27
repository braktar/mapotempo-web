# Copyright © Mapotempo, 2016
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
module VisitsHelper
  # return a blank hash if quantity is nil, the hash is never filled for nothing
  def visit_quantities(visit, vehicle, options = {})
    visit.destination.customer.deliverable_units.map{ |du|
      quantities = visit.send(:default_quantities)
      if quantities && quantities[du.id]
        {
          quantity: !options[:with_default] ? quantities[du.id] : quantities && quantities[du.id] && Visit.localize_numeric_value(quantities[du.id]) + (vehicle && vehicle.default_capacities[du.id] ? '/' + Visit.localize_numeric_value(vehicle.default_capacities[du.id]) : '') + (du.label ? "\u202F" + du.label : ''),
          unit_icon: du.default_icon
        }
      end
    }.compact
  end
end
