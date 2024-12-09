# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_12_09_145534) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_columns", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "data_type"
    t.boolean "is_deduction"
    t.boolean "include_in_payroll"
    t.boolean "not_subject_to_withholding"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_custom_columns_on_company_id"
  end

  create_table "departments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "employee_number"
    t.string "payroll_type"
    t.decimal "pay_rate", precision: 12, scale: 2
    t.string "filing_status"
    t.decimal "retirement_rate", precision: 5, scale: 4
    t.decimal "roth_retirement_rate", precision: 5, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_employees_on_department_id"
  end

  create_table "payroll_records", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "pay_period_start"
    t.date "pay_period_end"
    t.decimal "hours_worked", precision: 12, scale: 2
    t.decimal "overtime_hours_worked", precision: 12, scale: 2
    t.decimal "reported_tips", precision: 12, scale: 2
    t.decimal "bonus", precision: 12, scale: 2
    t.decimal "gross_pay", precision: 12, scale: 2
    t.decimal "net_pay", precision: 12, scale: 2
    t.decimal "withholding_tax", precision: 12, scale: 2
    t.decimal "social_security_tax", precision: 12, scale: 2
    t.decimal "medicare_tax", precision: 12, scale: 2
    t.decimal "retirement_payment", precision: 12, scale: 2
    t.decimal "roth_retirement_payment", precision: 12, scale: 2
    t.decimal "total_deductions", precision: 12, scale: 2
    t.decimal "total_additions", precision: 12, scale: 2
    t.string "status"
    t.jsonb "custom_columns_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_payroll_records_on_employee_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "custom_columns", "companies"
  add_foreign_key "departments", "companies"
  add_foreign_key "employees", "departments"
  add_foreign_key "payroll_records", "employees"
end
