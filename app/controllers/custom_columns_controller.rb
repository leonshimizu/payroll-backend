class CustomColumnsController < ApplicationController
  before_action :authorize_request
  before_action :set_company
  before_action :set_custom_column, only: [ :update, :destroy ]
  before_action :require_admin, except: [ :index ]

  def index
    @custom_columns = @company.custom_columns
    render json: @custom_columns
  end

  def create
    @custom_column = @company.custom_columns.new(custom_column_params)
    if @custom_column.save
      render json: @custom_column, status: :created
    else
      render json: { errors: @custom_column.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @custom_column.update(custom_column_params)
      render json: @custom_column
    else
      render json: { errors: @custom_column.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_column.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_custom_column
    @custom_column = @company.custom_columns.find(params[:id])
  end

  def custom_column_params
    params.require(:custom_column).permit(:name, :data_type, :is_deduction, :include_in_payroll, :not_subject_to_withholding)
  end

  def require_admin
    head :forbidden if current_user.role != "admin"
  end
end
