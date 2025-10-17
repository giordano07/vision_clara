require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "should not save budget without nombre" do
    budget = Budget.new(telefono: "123456789", dni: "12345678", email: "test@test.com")
    assert_not budget.save, "Saved the budget without a nombre"
  end

  test "should not save budget without telefono" do
    budget = Budget.new(nombre: "Juan Perez", dni: "12345678", email: "test@test.com")
    assert_not budget.save, "Saved the budget without a telefono"
  end

  test "should not save budget without dni" do
    budget = Budget.new(nombre: "Juan Perez", telefono: "123456789", email: "test@test.com")
    assert_not budget.save, "Saved the budget without a dni"
  end

  test "should not save budget without email" do
    budget = Budget.new(nombre: "Juan Perez", telefono: "123456789", dni: "12345678")
    assert_not budget.save, "Saved the budget without an email"
  end

  test "should not save budget with invalid email" do
    budget = Budget.new(nombre: "Juan Perez", telefono: "123456789", dni: "12345678", email: "invalid-email")
    assert_not budget.save, "Saved the budget with an invalid email"
  end

  test "should save budget with all valid attributes" do
    budget = Budget.new(nombre: "Juan Perez", telefono: "123456789", dni: "12345678", email: "test@test.com")
    assert budget.save, "Failed to save the budget with valid attributes"
  end
end
