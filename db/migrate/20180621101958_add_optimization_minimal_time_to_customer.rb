class AddOptimizationMinimalTimeToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :optimization_minimal_time, :integer
  end
end
