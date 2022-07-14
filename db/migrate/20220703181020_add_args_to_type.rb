class AddArgsToType < ActiveRecord::Migration[7.0]
  def change
    add_column :types, :args, :text
  end
end
