class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.string :idempotency_key, null: false
      t.integer :status, default: 0
      t.json :payload
      t.text :error_message

      t.timestamps
    end

    add_index :requests, :idempotency_key, unique: true
    add_index :requests, :status
    
  end
end
