class Company < ApplicationRecord
  has_many :departments, dependent: :destroy
  has_many :employees, through: :departments
  has_many :custom_columns, dependent: :destroy

  has_many :payroll_records, through: :employees

  validates :name, presence: true

  def employee_count
    employees.count
  end
end
