require "test_helper"

class BudgetMailerTest < ActionMailer::TestCase
  test "notification_to_admin" do
    budget = Budget.create!(
      nombre: "Juan Perez",
      telefono: "123456789",
      dni: "12345678",
      email: "juan@example.com",
      tipo_lentes: "Lentes de sol",
      motivo: "Necesito lentes nuevos"
    )

    email = BudgetMailer.notification_to_admin(budget)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["admin@opticacofico.com"], email.to
    assert_equal "Nueva solicitud de presupuesto de Juan Perez", email.subject
    assert_match "Juan Perez", email.body.encoded
    assert_match "123456789", email.body.encoded
  end

  test "confirmation_to_client" do
    budget = Budget.create!(
      nombre: "Juan Perez",
      telefono: "123456789",
      dni: "12345678",
      email: "juan@example.com"
    )

    email = BudgetMailer.confirmation_to_client(budget)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["juan@example.com"], email.to
    assert_equal "Hemos recibido tu solicitud de presupuesto", email.subject
    assert_match "Juan Perez", email.body.encoded
    assert_match "Hemos recibido tu solicitud", email.body.encoded
  end
end


