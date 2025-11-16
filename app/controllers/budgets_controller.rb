class BudgetsController < ApplicationController
  def new
    @budget = Budget.new
  end

  def create
    @budget = Budget.new(budget_params)

    begin
      if @budget.save
        begin
          # Enviar emails de notificación (no bloquear la UX si hay un error externo)
          BudgetMailer.notification_to_admin(@budget).deliver_later
          BudgetMailer.confirmation_to_client(@budget).deliver_later
        rescue StandardError => e
          Rails.logger.error("[BudgetsController#create] Error al enviar correos: #{e.class} - #{e.message}")
        end

        redirect_to root_path, notice: "¡Gracias! Hemos recibido tu solicitud de presupuesto. Te contactaremos pronto."
      else
        flash.now[:alert] = "Hubo un error al enviar tu solicitud. Por favor, revisa los campos marcados y vuelve a intentar."
        render :new, status: :unprocessable_entity
      end
    rescue StandardError => e
      # Capturar cualquier error durante el guardado (incluyendo errores de Active Storage)
      Rails.logger.error("[BudgetsController#create] Error al guardar presupuesto: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      # Intentar guardar sin la imagen si el error está relacionado con Active Storage
      if e.message.include?("solid_queue") || e.message.include?("ActiveStorage") || e.message.include?("queue")
        @budget.imagen = nil
        if @budget.save
          redirect_to root_path, notice: "¡Gracias! Hemos recibido tu solicitud de presupuesto (sin imagen). Te contactaremos pronto."
        else
          flash.now[:alert] = "Hubo un error al enviar tu solicitud. Por favor, intenta nuevamente sin la imagen."
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "Hubo un error inesperado al enviar tu solicitud. Por favor, intenta nuevamente."
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def budget_params
    params.require(:budget).permit(:nombre, :telefono, :dni, :email, :motivo, :preferencia_contacto, :horario_preferido, :tipo_lentes, :imagen)
  end
end
