class AddTitleToType < ActiveRecord::Migration[7.0]
  def change
    add_column :types, :title, :string
  end
end
