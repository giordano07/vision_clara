class BudgetMailer < ApplicationMailer
  default from: 'noreply@opticacofico.com'

  def notification_to_admin(budget)
    @budget = budget
    mail(
      to: 'admin@opticacofico.com',
      subject: "Nueva solicitud de presupuesto de #{budget.nombre}"
    )
  end

  def confirmation_to_client(budget)
    @budget = budget
    mail(
      to: budget.email,
      subject: "Hemos recibido tu solicitud de presupuesto"
    )
  end
end


