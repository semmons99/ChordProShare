class CreateDocs < ActiveRecord::Migration
  def change
    create_table :docs do |t|
      t.integer :user_id, null: false
      t.string  :name,    null: false
      t.text    :markup

      t.timestamps
    end

    add_index :docs, %w(user_id name), unique: true
  end
end
