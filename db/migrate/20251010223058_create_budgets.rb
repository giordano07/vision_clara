class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :budgets do |t|
      t.string :nombre
      t.string :telefono
      t.string :dni
      t.string :email

      t.timestamps
    end
  end
end
