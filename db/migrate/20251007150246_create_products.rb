class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :nombre
      t.text :descripcion
      t.decimal :precio, precision: 10, scale: 2
      t.boolean :activo, default: true, null: false

      t.timestamps
    end
  end
end
