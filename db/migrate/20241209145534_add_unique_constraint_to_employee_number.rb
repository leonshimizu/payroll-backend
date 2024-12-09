class AddUniqueConstraintToEmployeeNumber < ActiveRecord::Migration[7.0]
  def change
    change_column_null :employees, :employee_number, false
    add_index :employees, :employee_number, unique: true
  end
end
