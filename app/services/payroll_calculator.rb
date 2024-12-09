# app/services/payroll_calculator.rb
class PayrollCalculator
  attr_reader :employee, :company, :payroll_record

  def initialize(employee, company, payroll_record)
    @employee = employee
    @company = company
    @payroll_record = payroll_record
  end

  def calculate
    raise NotImplementedError, "Subclasses must implement"
  end

  protected

  def calculate_withholding
    gross = payroll_record.gross_pay
    payroll_record.withholding_tax = Calculator.calculate_withholding(gross, employee.filing_status)
  end

  def calculate_social_security
    payroll_record.social_security_tax = Calculator.calculate_social_security(payroll_record.gross_pay)
  end

  def calculate_medicare
    payroll_record.medicare_tax = Calculator.calculate_medicare(payroll_record.gross_pay)
  end

  def calculate_retirement_payment
    payroll_record.retirement_payment = (payroll_record.gross_pay * employee.retirement_rate.to_f).round(2)
  end

  def calculate_roth_retirement_payment
    payroll_record.roth_retirement_payment = (payroll_record.gross_pay * employee.roth_retirement_rate.to_f).round(2)
  end

  def calculate_total_deductions_and_additions
    payroll_record.total_deductions = (
      payroll_record.withholding_tax.to_f +
      payroll_record.social_security_tax.to_f +
      payroll_record.medicare_tax.to_f +
      payroll_record.retirement_payment.to_f +
      payroll_record.roth_retirement_payment.to_f
    ).round(2)

    payroll_record.total_additions = (payroll_record.bonus.to_f + payroll_record.reported_tips.to_f)
  end

  def calculate_net_pay
    payroll_record.net_pay = (payroll_record.gross_pay +
                              payroll_record.total_additions.to_f -
                              payroll_record.total_deductions.to_f).round(2)
  end
end
