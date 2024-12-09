class Department < ApplicationRecord
  belongs_to :company
  has_many :employees, dependent: :destroy

  validates :name, presence: true
end
