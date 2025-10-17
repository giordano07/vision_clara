class Budget < ApplicationRecord
  has_one_attached :imagen

  PREFERENCIAS_CONTACTO = ["Teléfono", "Email", "WhatsApp"].freeze
  HORARIOS_PREFERIDOS = ["Mañana (9-12hs)", "Mediodía (12-15hs)", "Tarde (15-18hs)", "Noche (18-20hs)"].freeze
  TIPOS_LENTES = ["Lentes de sol", "Lentes recetados", "Lentes de contacto", "Otro"].freeze

  validates :nombre, presence: true
  validates :telefono, presence: true
  validates :dni, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Atributos que pueden ser buscados con Ransack en ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    ["nombre", "telefono", "dni", "email", "motivo", "preferencia_contacto", "horario_preferido", "tipo_lentes", "created_at", "updated_at"]
  end

  # Asociaciones que pueden ser buscadas con Ransack
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
