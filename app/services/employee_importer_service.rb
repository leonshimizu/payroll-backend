# app/services/employee_importer_service.rb
class EmployeeImporterService
  def initialize(company, file)
    @company = company
    @file = file
  end

  def call
    @created_count = 0
    @updated_count = 0
    @errors = []

    # Roo will auto-detect file type. Ensure it's an .xlsx file when testing.
    spreadsheet = Roo::Spreadsheet.open(@file.tempfile)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[ header, spreadsheet.row(i) ].transpose]

      # Example expected columns:
      # employee_number, first_name, last_name, department_name (or department_id),
      # payroll_type, pay_rate, filing_status, retirement_rate, roth_retirement_rate

      department = if row["department_id"]
                      @company.departments.find_by(id: row["department_id"])
      elsif row["department_name"]
                      @company.departments.find_by(name: row["department_name"])
      end

      unless department
        @errors << "Row #{i}: Department not found"
        next
      end

      employee_number = row["employee_number"].to_s.strip
      if employee_number.blank?
        @errors << "Row #{i}: employee_number is blank"
        next
      end

      employee = @company.employees.find_by(employee_number: employee_number) || department.employees.new
      employee.assign_attributes(
        first_name: row["first_name"],
        last_name: row["last_name"],
        department_id: department.id,
        payroll_type: row["payroll_type"],
        pay_rate: row["pay_rate"],
        filing_status: row["filing_status"],
        retirement_rate: row["retirement_rate"],
        roth_retirement_rate: row["roth_retirement_rate"]
      )

      if employee.new_record?
        if employee.save
          @created_count += 1
        else
          @errors << "Row #{i}: #{employee.errors.full_messages.join(', ')}"
        end
      else
        if employee.changed?
          if employee.save
            @updated_count += 1
          else
            @errors << "Row #{i}: #{employee.errors.full_messages.join(', ')}"
          end
        end
      end
    end

    {
      success: @errors.empty?,
      created_count: @created_count,
      updated_count: @updated_count,
      errors: @errors
    }
  end
end
