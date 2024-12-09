class SalaryPayrollCalculator < PayrollCalculator
  def calculate
    calculate_gross_pay
    calculate_retirement_payment
    calculate_roth_retirement_payment
    calculate_withholding
    calculate_social_security
    calculate_medicare
    payroll_record.calculate_total_deductions_and_additions
    calculate_net_pay
  end

  private

  def calculate_gross_pay
    # Assuming employee.pay_rate is per pay period or annual divided by pay periods handled externally.
    # If pay_rate is per pay period (e.g., bi-weekly), then:
    payroll_record.gross_pay = employee.pay_rate.round(2)
    payroll_record.gross_pay += payroll_record.bonus.to_f if payroll_record.bonus.present?
  end
end
