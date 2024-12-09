class PayrollRecordsController < ApplicationController
  before_action :authorize_request
  before_action :set_company
  before_action :set_payroll_record, only: [ :update, :destroy ]
  before_action :require_admin, except: [ :index ]

  def index
    # Later, we can add filters (date range, employee, etc.)
    @payroll_records = @company.payroll_records.includes(:employee)
    render json: @payroll_records
  end

  def create
    # Assume we get an employee_id in params
    employee = @company.employees.find(params[:payroll_record][:employee_id])
    @payroll_record = employee.payroll_records.new(payroll_record_params)
    if @payroll_record.save
      render json: @payroll_record, status: :created
    else
      render json: { errors: @payroll_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @payroll_record.update(payroll_record_params)
      render json: @payroll_record
    else
      render json: { errors: @payroll_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @payroll_record.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_payroll_record
    @payroll_record = @company.payroll_records.find(params[:id])
  end

  def payroll_record_params
    params.require(:payroll_record).permit(:employee_id, :pay_period_start, :pay_period_end, :hours_worked, :overtime_hours_worked, :reported_tips, :bonus)
  end

  def require_admin
    head :forbidden if current_user.role != "admin"
  end
end
