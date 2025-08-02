class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.references :team, null: false, foreign_key: true
      t.string :status, default: 'active'

      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :name
  end
end
