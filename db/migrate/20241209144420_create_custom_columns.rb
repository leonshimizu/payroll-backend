class CreateCustomColumns < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_columns do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :data_type, default: "decimal"
      t.boolean :is_deduction, default: false
      t.boolean :include_in_payroll, default: true
      t.boolean :not_subject_to_withholding, default: false

      t.timestamps
    end
  end
end
