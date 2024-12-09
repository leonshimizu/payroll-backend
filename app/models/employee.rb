class Employee < ApplicationRecord
  belongs_to :department
  has_one :company, through: :department
  has_many :payroll_records, dependent: :destroy
end
