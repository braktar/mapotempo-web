# Copyright © Mapotempo, 2014-2015
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
class V01::Entities::Destination < Grape::Entity
  def self.entity_name
    'V01_Destination'
  end

  expose(:id, documentation: { type: Integer })
  expose(:name, documentation: { type: String })
  expose(:street, documentation: { type: String })
  expose(:postalcode, documentation: { type: String })
  expose(:city, documentation: { type: String })
  expose(:country, documentation: { type: String })
  expose(:lat, documentation: { type: Float })
  expose(:lng, documentation: { type: Float })
  expose(:quantity, documentation: { type: Integer })
  expose(:open, documentation: { type: DateTime }) { |m| m.open && m.open.strftime('%H:%M:%S') }
  expose(:close, documentation: { type: DateTime }) { |m| m.close && m.close.strftime('%H:%M:%S') }
  expose(:detail, documentation: { type: String })
  expose(:comment, documentation: { type: String })
  expose(:ref, documentation: { type: String })
  expose(:take_over, documentation: { type: DateTime }) { |m| m.take_over && m.take_over.strftime('%H:%M:%S') }
  expose(:take_over_default, documentation: { type: DateTime }) { |m| m.customer && m.customer.take_over && m.customer.take_over.strftime('%H:%M:%S') }
  expose(:tag_ids, documentation: { type: Integer, is_array: true })
  expose(:geocoding_accuracy, documentation: { type: Float })
  expose(:geocoding_level, documentation: { type: String, values: ['point', 'house', 'street', 'intersection', 'city'] })
end
