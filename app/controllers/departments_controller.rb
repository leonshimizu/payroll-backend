class DepartmentsController < ApplicationController
  before_action :authorize_request
  before_action :set_company
  before_action :set_department, only: [ :update, :destroy ]
  before_action :require_admin, except: [ :index ]

  def index
    @departments = @company.departments
    render json: @departments
  end

  def create
    @department = @company.departments.new(department_params)
    if @department.save
      render json: @department, status: :created
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @department.update(department_params)
      render json: @department
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @department.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_department
    @department = @company.departments.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name)
  end

  def require_admin
    head :forbidden if current_user.role != "admin"
  end
end
