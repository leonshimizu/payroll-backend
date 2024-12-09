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
      # Join employees and filter by department
      records = records.joins(:employee).where(employees: { department_id: params[:department_id] })
    end

    render json: records
  end

  def create
    @payroll_record = @company.payroll_records.new(payroll_record_params)
    @payroll_record.employee_id = params[:employee_id] if params[:employee_id].present?

    if @payroll_record.employee.nil?
      render json: { error: "Employee not found or not provided" }, status: :unprocessable_entity
      return
    end

    calculate_payroll(@payroll_record)
    if @payroll_record.save
      render json: @payroll_record, status: :created
    else
      render json: { errors: @payroll_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk
    if params[:file].present?
      # Parse Excel file using Roo
      xlsx = Roo::Spreadsheet.open(params[:file].path)
      sheet = xlsx.sheet(0)

      # Assuming first row is headers
      headers = sheet.row(1).map(&:to_s) # convert headers to string keys
      # Example expected headers: ["employee_id", "hours_worked", "overtime_hours_worked", "reported_tips", "bonus", "pay_period_start", "pay_period_end"]

      records_data = []
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        record_hash = {}
        headers.each_with_index do |header, idx|
          record_hash[header] = row[idx]
        end
        records_data << record_hash
      end
    else
      records_data = params[:records]
    end

    created_records = []
    errors = []
    records_data.each do |record_data|
      # Convert keys to symbols if needed
      record_data = record_data.transform_keys(&:to_sym)

      pr = @company.payroll_records.new(record_data.slice(:employee_id, :hours_worked, :overtime_hours_worked, :reported_tips, :bonus, :pay_period_start, :pay_period_end))

      if pr.employee.nil?
        errors << "Invalid or missing employee_id for record: #{record_data}"
        next
      end

      calculate_payroll(pr)

      if pr.save
        created_records << pr
      else
        errors << pr.errors.full_messages
      end
    end

    if errors.empty?
      render json: created_records, status: :created
    else
      render json: { errors: errors }, status: :unprocessable_entity
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

  def calculate_payroll(payroll_record)
    employee = payroll_record.employee
    calculator = if employee.payroll_type == "hourly"
                   HourlyPayrollCalculator.new(payroll_record, employee)
    else
                   SalaryPayrollCalculator.new(payroll_record, employee)
    end
    calculator.calculate
  end
end
