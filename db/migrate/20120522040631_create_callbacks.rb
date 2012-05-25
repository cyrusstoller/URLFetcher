class CreateCallbacks < ActiveRecord::Migration
  def change
    create_table :callbacks do |t|
      t.integer :callbackable_id
      t.string :callbackable_type
      t.integer :status

      t.timestamps
    end
  end
end
