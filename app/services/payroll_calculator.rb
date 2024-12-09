class PayrollCalculator
  attr_reader :payroll_record, :employee

  def initialize(payroll_record, employee)
    @payroll_record = payroll_record
    @employee = employee
  end

  def calculate
    # To be implemented by subclasses
    raise NotImplementedError
  end

  protected

  def calculate_retirement_payment
    payroll_record.retirement_payment = (payroll_record.gross_pay * employee.retirement_rate).round(2)
  end

  def calculate_roth_retirement_payment
    payroll_record.roth_retirement_payment = (payroll_record.gross_pay * employee.roth_retirement_rate).round(2)
  end

  def calculate_withholding
    payroll_record.withholding_tax = Calculator.calculate_withholding(payroll_record.gross_pay, employee.filing_status)
  end

  def calculate_social_security
    payroll_record.social_security_tax = Calculator.calculate_social_security(payroll_record.gross_pay)
  end

  def calculate_medicare
    payroll_record.medicare_tax = Calculator.calculate_medicare(payroll_record.gross_pay)
  end

  def calculate_net_pay
    payroll_record.calculate_total_deductions_and_additions
    payroll_record.net_pay = (payroll_record.gross_pay - payroll_record.total_deductions).round(2)
  end
end
