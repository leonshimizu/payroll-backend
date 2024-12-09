require 'faker'

# Create an admin user to log into the system
admin_user = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "Password123",
  password_confirmation: "Password123",
  role: "admin"
)

puts "Created admin user: #{admin_user.email}"

# Create a regular user if you'd like
regular_user = User.create!(
  name: "Regular User",
  email: "user@example.com",
  password: "Password123",
  password_confirmation: "Password123",
  role: "regular"
)

puts "Created regular user: #{regular_user.email}"

# Seed multiple companies
company_names = [
  { name: "Acme Corporation", address: "123 Main St", location: "New York, NY" },
  { name: "TechStart Inc", address: "456 Market St", location: "San Francisco, CA" },
  { name: "Global Solutions Ltd", address: "789 Business Ave", location: "Chicago, IL" }
]

companies = company_names.map do |attrs|
  Company.create!(attrs)
end

puts "Created #{companies.count} companies"

# For each company, create departments and employees
departments_per_company = [ "Engineering", "Marketing", "Sales", "HR", "Finance", "Operations" ]
payroll_types = [ "hourly", "salary" ]
filing_statuses = [ "single", "married", "head_of_household" ]

companies.each do |company|
  # Randomize how many departments per company
  dept_count = rand(3..5)
  depts = departments_per_company.sample(dept_count).map do |dept_name|
    Department.create!(
      company: company,
      name: dept_name
    )
  end

  puts "Created #{depts.count} departments for #{company.name}"

  # Create employees for each department
  total_emps = 0
  depts.each do |dept|
    emp_count = rand(5..10)
    emp_count.times do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      employee_number = "EMP#{Faker::Number.unique.number(digits: 3)}"
      payroll_type = payroll_types.sample
      pay_rate = payroll_type == "hourly" ? Faker::Number.between(from: 20.0, to: 50.0) : Faker::Number.between(from: 50000.0, to: 120000.0)
      filing_status = filing_statuses.sample
      retirement_rate = Faker::Number.between(from: 0.02, to: 0.06).round(4)
      roth_retirement_rate = Faker::Number.between(from: 0.0, to: 0.03).round(4)

      Employee.create!(
        department: dept,
        first_name: first_name,
        last_name: last_name,
        employee_number: employee_number,
        payroll_type: payroll_type,
        pay_rate: pay_rate,
        filing_status: filing_status,
        retirement_rate: retirement_rate,
        roth_retirement_rate: roth_retirement_rate
      )
    end
    total_emps += emp_count
  end

  puts "Created #{total_emps} employees for #{company.name}"

  # Create some custom columns for the company
  custom_columns = [
    { name: "Parking Fee", data_type: "decimal", is_deduction: true, include_in_payroll: true, not_subject_to_withholding: true },
    { name: "Health Insurance", data_type: "decimal", is_deduction: true, include_in_payroll: true, not_subject_to_withholding: false },
    { name: "Commission", data_type: "decimal", is_deduction: false, include_in_payroll: true, not_subject_to_withholding: false },
    { name: "Gym Membership", data_type: "decimal", is_deduction: true, include_in_payroll: false, not_subject_to_withholding: true }
  ]

  custom_columns.sample(rand(1..3)).each do |col_attrs|
    company.custom_columns.create!(col_attrs)
  end
  puts "Created #{company.custom_columns.count} custom columns for #{company.name}"

  # Create some payroll records for employees
  # Let's say we create records for the last 3 months, semi-monthly pay periods.
  employees = company.employees
  pay_periods = [
    { start: Date.today.last_month.beginning_of_month, end: Date.today.last_month.beginning_of_month + 14 },
    { start: Date.today.last_month.beginning_of_month + 15, end: Date.today.last_month.end_of_month },
    { start: Date.today.beginning_of_month, end: Date.today.beginning_of_month + 14 },
    { start: Date.today.beginning_of_month + 15, end: Date.today.end_of_month }
  ]

  pay_periods.each do |pp|
    employees.each do |emp|
      hours_worked = emp.payroll_type == "hourly" ? Faker::Number.between(from: 70.0, to: 90.0) : 80.0
      overtime_hours_worked = emp.payroll_type == "hourly" ? Faker::Number.between(from: 0.0, to: 10.0) : 0.0
      reported_tips = emp.payroll_type == "hourly" && [ true, false ].sample ? Faker::Number.between(from: 0.0, to: 200.0) : 0.0
      bonus = [ 0.0, 100.0, 200.0 ].sample

      gross_pay = if emp.payroll_type == "hourly"
                     (hours_worked * emp.pay_rate) + (overtime_hours_worked * emp.pay_rate * 1.5) + bonus + reported_tips
      else
                     # Approximate semi-monthly salary distribution:
                     (emp.pay_rate / 24) + bonus
      end

      withholding_tax = gross_pay * 0.15
      social_security_tax = gross_pay * 0.062
      medicare_tax = gross_pay * 0.0145
      retirement_payment = gross_pay * emp.retirement_rate
      roth_retirement_payment = gross_pay * emp.roth_retirement_rate
      total_deductions = withholding_tax + social_security_tax + medicare_tax + retirement_payment + roth_retirement_payment
      total_additions = bonus + reported_tips

      # Custom columns data:
      columns_data = {}
      emp.company.custom_columns.each do |cc|
        # If it's a deduction, let's say a random amount:
        if cc.is_deduction
          columns_data[cc.name] = Faker::Number.between(from: 10.0, to: 50.0)
          total_deductions += columns_data[cc.name].to_f if cc.include_in_payroll
        else
          # Maybe a random addition:
          columns_data[cc.name] = Faker::Number.between(from: 50.0, to: 200.0)
          total_additions += columns_data[cc.name].to_f if cc.include_in_payroll
        end
      end

      net_pay = gross_pay + (total_additions - total_deductions)

      PayrollRecord.create!(
        employee: emp,
        pay_period_start: pp[:start],
        pay_period_end: pp[:end],
        hours_worked: hours_worked,
        overtime_hours_worked: overtime_hours_worked,
        reported_tips: reported_tips,
        bonus: bonus,
        gross_pay: gross_pay,
        net_pay: net_pay,
        withholding_tax: withholding_tax,
        social_security_tax: social_security_tax,
        medicare_tax: medicare_tax,
        retirement_payment: retirement_payment,
        roth_retirement_payment: roth_retirement_payment,
        total_deductions: total_deductions,
        total_additions: total_additions,
        status: [ "pending", "processed", "paid" ].sample,
        custom_columns_data: columns_data
      )
    end
  end

  puts "Created payroll records for #{company.name}"
end

puts "Seeding complete!"
