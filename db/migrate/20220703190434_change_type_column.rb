class ChangeTypeColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :params, :type, :tname
  end
end
