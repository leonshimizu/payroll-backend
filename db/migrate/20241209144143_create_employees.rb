class CreateEmployees < ActiveRecord::Migration[6.1]
  def change
    create_table :employees do |t|
      t.references :department, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :employee_number
      t.string :payroll_type
      t.decimal :pay_rate, precision: 12, scale: 2
      t.string :filing_status
      t.decimal :retirement_rate, precision: 5, scale: 4
      t.decimal :roth_retirement_rate, precision: 5, scale: 4

      t.timestamps
    end
  end
end
