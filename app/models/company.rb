class Company < ApplicationRecord
  has_many :departments, dependent: :destroy
  has_many :employees, through: :departments
  has_many :custom_columns, dependent: :destroy
end
