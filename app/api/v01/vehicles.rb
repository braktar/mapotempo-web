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
require 'coerce'

class V01::Vehicles < Grape::API
  helpers do
    # Never trust parameters from the scary internet, only allow the white list through.
    def vehicle_params
      p = ActionController::Parameters.new(params)
      p = p[:vehicle] if p.key?(:vehicle)
      p.permit(:ref, :name, :emission, :consumption, :capacity, :color, :open, :close, :tomtom_id, :masternaut_ref, :store_start_id, :store_stop_id, :router_id, :speed_multiplicator, :rest_start, :rest_stop, :rest_duration, :store_rest_id)
    end

    ID_DESC = 'Id or the ref field value, then use "ref:[value]".'
  end

  resource :vehicles do
    desc 'Fetch customer\'s vehicles.',
      nickname: 'getVehicles',
      is_array: true,
      entity: V01::Entities::Vehicle
    params do
      optional :ids, type: Array[String], desc: 'Select returned vehicles by id separated with comma. You can specify ref (not containing comma) instead of id, in this case you have to add "ref:" before each ref, e.g. ref:ref1,ref:ref2,ref:ref3.', coerce_with: CoerceArrayString
    end
    get do
      vehicles = if params.key?(:ids)
        current_customer.vehicles.select{ |vehicle|
          params[:ids].any?{ |s| ParseIdsRefs.match(s, vehicle) }
        }
      else
        current_customer.vehicles.load
      end
      present vehicles, with: V01::Entities::Vehicle
    end

    desc 'Fetch vehicle.',
      nickname: 'getVehicle',
      entity: V01::Entities::Vehicle
    params do
      requires :id, type: String, desc: ID_DESC
    end
    get ':id' do
      id = ParseIdsRefs.read(params[:id])
      present current_customer.vehicles.where(id).first!, with: V01::Entities::Vehicle
    end

    desc 'Update vehicle.',
      nickname: 'updateVehicle',
      params: V01::Entities::Vehicle.documentation.except(:id),
      entity: V01::Entities::Vehicle
    params do
      requires :id, type: String, desc: ID_DESC
    end
    put ':id' do
      id = ParseIdsRefs.read(params[:id])
      vehicle = current_customer.vehicles.where(id).first!
      vehicle.update(vehicle_params)
      vehicle.save!
      present vehicle, with: V01::Entities::Vehicle
    end

    desc 'Create vehicle.',
      nickname: 'createVehicle',
      params: V01::Entities::Vehicle.documentation.except(:id).deep_merge(
        name: { required: true },
        store_start_id: { required: true },
        store_stop_id: { required: true }
      ),
      entity: V01::Entities::Vehicle
    if Mapotempo::Application.config.manage_vehicles_only_admin
      params do
        requires :customer_id, type: Integer
      end
    end
    post do
      if Mapotempo::Application.config.manage_vehicles_only_admin
        if @current_user.admin?
          customer = Customer.where(id: params[:customer_id]).first!
          vehicle = customer.vehicles.build(vehicle_params)
          vehicle.save!
        else
          error! 'Forbidden', 403
        end
      else
        vehicle = current_customer.vehicles.build(vehicle_params)
        vehicle.save!
      end
      present vehicle, with: V01::Entities::Vehicle
    end

    desc 'Delete vehicle.',
      nickname: 'deleteVehicle'
    params do
      requires :id, type: String, desc: ID_DESC
    end
    delete ':id' do
      id = ParseIdsRefs.read(params[:id])
      if Mapotempo::Application.config.manage_vehicles_only_admin
        if @current_user.admin?
          Vehicle.where(id).first!.destroy
        else
          error! 'Forbidden', 403
        end
      else
        current_customer.vehicles.where(id).first!.destroy
      end
    end

    desc 'Delete multiple vehicles.',
      nickname: 'deleteVehicles'
    params do
      requires :ids, type: Array[String], desc: 'Ids separated by comma. You can specify ref (not containing comma) instead of id, in this case you have to add "ref:" before each ref, e.g. ref:ref1,ref:ref2,ref:ref3.', coerce_with: CoerceArrayString
    end
    delete do
      Vehicle.transaction do
        if Mapotempo::Application.config.manage_vehicles_only_admin
          if @current_user.admin?
            Vehicle.select{ |vehicle|
              params[:ids].any?{ |s| ParseIdsRefs.match(s, vehicle) }
            }.each(&:destroy)
          else
            error! 'Forbidden', 403
          end
        else
          current_customer.vehicles.select{ |vehicle|
            params[:ids].any?{ |s| ParseIdsRefs.match(s, vehicle) }
          }.each(&:destroy)
        end
      end
    end
  end
end
