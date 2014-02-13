class CreateRequest < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :resources
      t.string :user
      t.datetime :from
      t.datetime :to, null: true
      t.string :status
  end
  add_index :resources, :id
  end
end

