require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_budget_url
    assert_response :success
  end

  test "should create budget with valid attributes" do
    assert_difference("Budget.count") do
      post budgets_url, params: { 
        budget: { 
          nombre: "Juan Perez", 
          telefono: "123456789", 
          dni: "12345678", 
          email: "test@test.com",
          tipo_lentes: "Lentes de sol",
          motivo: "Necesito lentes nuevos",
          preferencia_contacto: "Email",
          horario_preferido: "Mañana (9-12hs)"
        } 
      }
    end

    assert_redirected_to root_path
  end

  test "should send emails when budget is created" do
    assert_enqueued_emails 2 do
      post budgets_url, params: { 
        budget: { 
          nombre: "Juan Perez", 
          telefono: "123456789", 
          dni: "12345678", 
          email: "test@test.com"
        } 
      }
    end
  end

  test "should not create budget with invalid attributes" do
    assert_no_difference("Budget.count") do
      post budgets_url, params: { budget: { nombre: "", telefono: "", dni: "", email: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should not create budget with invalid email" do
    assert_no_difference("Budget.count") do
      post budgets_url, params: { budget: { nombre: "Juan Perez", telefono: "123456789", dni: "12345678", email: "invalid-email" } }
    end

    assert_response :unprocessable_entity
  end
end
