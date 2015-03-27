require 'tomtom'

class V01::Customers < Grape::API
  helpers do
    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      p = ActionController::Parameters.new(params)
      p = p[:customer] if p.key?(:customer)
      if @current_user.admin?
        p.permit(:name, :end_subscription, :max_vehicles, :take_over, :print_planning_annotating, :print_header, :tomtom_account, :tomtom_user, :tomtom_password, :masternaut_user, :masternaut_password, :router_id, :enable_orders, :test, :alyacom_association, :optimization_cluster_size)
      else
        p.permit(:take_over, :print_planning_annotating, :print_header, :tomtom_account, :tomtom_user, :tomtom_password, :masternaut_user, :masternaut_password, :router_id, :alyacom_association)
      end
    end
  end

  resource :customers do
    desc 'Fetch customer.', {
      nickname: 'getCustomer',
      is_array: true,
      entity: V01::Entities::Customer
    }
    params {
      requires :id, type: Integer
    }
    get ':id' do
      present current_customer(params[:id]), with: V01::Entities::Customer
    end

    desc 'Update customer.', {
      nickname: 'updateCustomer',
      params: V01::Entities::Customer.documentation.except(:id),
      entity: V01::Entities::Customer
    }
    params {
      requires :id, type: Integer
    }
    put ':id' do
      current_customer(params[:id])
      @current_customer.update(customer_params)
      @current_customer.save!
      present @current_customer, with: V01::Entities::Customer
    end

    desc 'Return a job', {
      nickname: 'getJob'
    }
    params {
      requires :id, type: Integer
      requires :job_id, type: Integer
    }
    get ':id/job/:job_id' do
      current_customer(params[:id])
      if @current_customer.job_optimizer && @current_customer.job_optimizer_id = params[:job_id]
        @current_customer.job_optimizer
      elsif @current_customer.job_geocoding && @current_customer.job_geocoding_id = params[:job_id]
        @current_customer.job_geocoding
      end
    end

    desc 'Cancel job', {
      nickname: 'deleteJob'
    }
    params {
      requires :id, type: Integer
      requires :job_id, type: Integer
    }
    delete ':id/job/:job_id' do
      current_customer(params[:id])
      if @current_customer.job_optimizer && @current_customer.job_optimizer_id = params[:job_id]
        @current_customer.job_optimizer.destroy
      elsif @current_customer.job_geocoding && @current_customer.job_geocoding_id = params[:job_id]
        @current_customer.job_geocoding.destroy
      end
    end

    desc 'Fetch tomtom ids.', {
      nickname: 'getTomtomIds'
    }
    params {
      requires :id, type: Integer
    }
    get ':id/tomtom_ids' do
      current_customer(params[:id])
      Hash[Tomtom.fetch_device_id(@current_customer).collect{ |tomtom|
        [tomtom[:objectUid], "#{tomtom[:objectUid]} - #{tomtom[:objectName]}"]
      }]
    end
  end
end
