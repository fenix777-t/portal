class CreateDataFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :data_files do |t|

      t.timestamps
    end
  end
end
