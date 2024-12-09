class CompaniesController < ApplicationController
  before_action :authorize_request
  before_action :set_company, only: [ :show, :update, :destroy ]
  before_action :require_admin, except: [ :index, :show ]

  def index
    @companies = Company.all
    render json: @companies
  end

  def show
    render json: @company
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      render json: @company, status: :created
    else
      render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    head :no_content
  end

  private

  def company_params
    params.require(:company).permit(:name, :address, :location)
  end

  def set_company
    @company = Company.find(params[:id])
  end

  def require_admin
    head :forbidden if current_user.role != "admin"
  end
end
