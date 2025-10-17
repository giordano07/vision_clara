class AddFieldsToBudgets < ActiveRecord::Migration[8.0]
  def change
    add_column :budgets, :motivo, :text
    add_column :budgets, :preferencia_contacto, :string
    add_column :budgets, :horario_preferido, :string
    add_column :budgets, :tipo_lentes, :string
  end
end


