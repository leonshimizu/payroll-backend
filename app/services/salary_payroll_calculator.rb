# app/services/salary_payroll_calculator.rb
class SalaryPayrollCalculator < PayrollCalculator
  def calculate
    calculate_gross_pay
    calculate_retirement_payment
    calculate_roth_retirement_payment
    calculate_withholding
    calculate_social_security
    calculate_medicare
    calculate_total_deductions_and_additions
    calculate_net_pay
  end

  private

  def calculate_gross_pay
    # Example: Assume pay_rate is annual, and we pay bi-weekly (26 periods per year).
    # Add reported_tips and bonus if any.
    payroll_record.gross_pay = ((employee.pay_rate / 26.0) +
                                payroll_record.reported_tips.to_f +
                                payroll_record.bonus.to_f).round(2)
  end
end
