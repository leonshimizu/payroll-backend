class PayrollRecord < ApplicationRecord
  belongs_to :employee

  def calculate_total_deductions_and_additions
    # total_deductions might be withholding_tax + retirement_payment + roth_retirement_payment + social_security_tax + medicare_tax
    self.total_deductions = (withholding_tax.to_f + retirement_payment.to_f + roth_retirement_payment.to_f + social_security_tax.to_f + medicare_tax.to_f).round(2)
  end
end
