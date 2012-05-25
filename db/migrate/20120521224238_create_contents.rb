class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :url
      t.text :body
      t.string :callback_url
      t.integer :user_id, :default => 0
      t.integer :flag, :default => 0

      t.timestamps
    end
  end
end
