class DropActiveAdminComments < ActiveRecord::Migration[8.0]
  def change
    drop_table :active_admin_comments do |t|
      t.string :namespace
      t.text :body
      t.references :resource, polymorphic: true
      t.references :author, polymorphic: true
      t.timestamps
    end
  end
end
