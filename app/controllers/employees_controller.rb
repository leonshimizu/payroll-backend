class EmployeesController < ApplicationController
  before_action :authorize_request
  before_action :set_company
  before_action :set_employee, only: [ :show, :update, :destroy ]
  before_action :require_admin, except: [ :index, :show ]

  def index
    @employees = @company.employees
    render json: @employees
  end

  def show
    render json: @employee
  end

  def create
    @employee = @company.employees.new(employee_params)
    if @employee.save
      render json: @employee, status: :created
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      render json: @employee
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    head :no_content
  end

  def import
    if params[:file].blank?
      render json: { errors: "No file uploaded" }, status: :bad_request
      return
    end

    # We assume the file is an Excel file (e.g., .xlsx).
    service = EmployeeImporterService.new(@company, params[:file])
    result = service.call

    if result[:success]
      render json: {
        message: "Import completed",
        created_count: result[:created_count],
        updated_count: result[:updated_count],
        errors: result[:errors]
      }, status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_employee
    @employee = @company.employees.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:department_id, :first_name, :last_name, :employee_number, :payroll_type, :pay_rate, :filing_status, :retirement_rate, :roth_retirement_rate)
  end

  def require_admin
    head :forbidden if current_user.role != "admin"
  end
end
