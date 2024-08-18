# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :uuid, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.string :status, null: false
      t.string :customer_email, null: false
      t.string :customer_phone
      t.string :type
      t.references :merchant, foreign_key: { to_table: :users }
      t.references :reference_transaction, foreign_key: { to_table: :transactions }

      t.timestamps
    end

    add_index :transactions, :uuid, unique: true
  end
end
