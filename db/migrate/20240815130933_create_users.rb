# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :type
      t.string :name
      t.string :email, null: false, index: { unique: true }
      t.integer :status, default: 0, null: false
      t.text :description

      t.timestamps
    end
  end
end
