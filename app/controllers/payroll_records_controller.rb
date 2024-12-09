# app/controllers/payroll_records_controller.rb
class PayrollRecordsController < ApplicationController
  before_action :authorize_request
  before_action :set_company
  before_action :set_payroll_record, only: [ :update, :destroy ]
  before_action :require_admin, except: [ :index ]

  def index
    records = @company.payroll_records
    if params[:start_date].present?
      records = records.where("pay_period_start >= ?", params[:start_date])
    end
    if params[:end_date].present?
      records = records.where("pay_period_end <= ?", params[:end_date])
    end
    if params[:employee_id].present?
      records = records.where(employee_id: params[:employee_id])
    end
    if params[:department_id].present?
      records = records.joins(:employee).where(employees: { department_id: params[:department_id] })
    end

    render json: records
  end

  def create
    mapped_params = {
      employee_id: params[:employee_id],
      pay_period_start: params[:pay_period_start],
      pay_period_end: params[:pay_period_end],
      hours_worked: params[:regular_hours].to_f,
      overtime_hours_worked: params[:overtime_hours].to_f,
      reported_tips: params[:reported_tips].to_f,
      bonus: params[:bonus].to_f
    }

    # Find the employee in the context of the company
    employee = @company.employees.find(mapped_params[:employee_id])

    record = employee.payroll_records.new(mapped_params)

    calculator = select_calculator(employee, record)
    calculator.calculate

    if record.save
      render json: record, status: :created
    else
      render json: { error: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk
    results = []
    params[:records].each do |r|
      mapped = {
        employee_id: r[:employee_id],
        pay_period_start: r[:pay_period_start],
        pay_period_end: r[:pay_period_end],
        hours_worked: r[:regular_hours].to_f,
        overtime_hours_worked: r[:overtime_hours].to_f,
        reported_tips: r[:reported_tips].to_f,
        bonus: r[:bonus].to_f
      }

      record = @company.payroll_records.new(mapped)
      calculator = select_calculator(record.employee, record)
      calculator.calculate
      if record.save
        results << record
      else
        results << { error: record.errors.full_messages.join(", ") }
      end
    end

    render json: results, status: :created
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
    params.require(:payroll_record).permit(
      :employee_id,
      :pay_period_start,
      :pay_period_end,
      :hours_worked,
      :overtime_hours_worked,
      :reported_tips,
      :bonus,
      :gross_pay,
      :net_pay,
      :withholding_tax,
      :social_security_tax,
      :medicare_tax,
      :retirement_payment,
      :roth_retirement_payment,
      :total_deductions,
      :total_additions,
      :status,
      custom_columns_data: {}
    )
  end

  def require_admin
    head :forbidden if current_user.role != "admin"
  end

  def select_calculator(employee, record)
    if employee.payroll_type == "hourly"
      HourlyPayrollCalculator.new(employee, @company, record)
    else
      SalaryPayrollCalculator.new(employee, @company, record)
    end
  end
end
