class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  # Atributos que pueden ser buscados con Ransack en ActiveAdmin
  # NOTA: NO incluir encrypted_password, reset_password_token u otros datos sensibles
  def self.ransackable_attributes(auth_object = nil)
    ["email", "created_at", "updated_at"]
  end

  # Asociaciones que pueden ser buscadas con Ransack
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
