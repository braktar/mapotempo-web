# Copyright © Mapotempo, 2018
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
class VisitQuantities

  def self.normalize(visit, vehicle, options = {})
    options[:with_default] = true unless options.key? :with_default
    quantities = visit.send(options[:with_default] ? :default_quantities : :quantities)
    visit.destination.customer.deliverable_units.map{ |du|
      if quantities && (quantities[du.id] && quantities[du.id] != 0 || visit.quantities_operations[du.id])
        q = number_with_precision(quantities[du.id], precision: 2, delimiter: I18n.t('number.format.delimiter'), strip_insignificant_zeros: true).to_s
        q += '/' + number_with_precision(vehicle.default_capacities[du.id], precision: 2, delimiter: I18n.t('number.format.delimiter'), strip_insignificant_zeros: true).to_s if vehicle && vehicle.default_capacities[du.id]
        q += "\u202F" + du.label if du.label
        q = I18n.t("activerecord.attributes.deliverable_unit.operation_#{visit.quantities_operations[du.id]}") + " (#{q})" if visit.quantities_operations[du.id]
        {
          deliverable_unit_id: du.id,
          quantity: q,
          quantity_float: quantities[du.id],
          unit_icon: du.default_icon
        }
      end
    }.compact
  end

end
