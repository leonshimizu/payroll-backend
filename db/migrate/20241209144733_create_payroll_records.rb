class CreatePayrollRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :payroll_records do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :pay_period_start
      t.date :pay_period_end
      t.decimal :hours_worked, precision: 12, scale: 2
      t.decimal :overtime_hours_worked, precision: 12, scale: 2
      t.decimal :reported_tips, precision: 12, scale: 2
      t.decimal :bonus, precision: 12, scale: 2
      t.decimal :gross_pay, precision: 12, scale: 2
      t.decimal :net_pay, precision: 12, scale: 2
      t.decimal :withholding_tax, precision: 12, scale: 2
      t.decimal :social_security_tax, precision: 12, scale: 2
      t.decimal :medicare_tax, precision: 12, scale: 2
      t.decimal :retirement_payment, precision: 12, scale: 2
      t.decimal :roth_retirement_payment, precision: 12, scale: 2
      t.decimal :total_deductions, precision: 12, scale: 2
      t.decimal :total_additions, precision: 12, scale: 2
      t.string :status
      t.jsonb :custom_columns_data

      t.timestamps
    end
  end
end
