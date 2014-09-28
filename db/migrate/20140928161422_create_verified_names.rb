class CreateVerifiedNames < ActiveRecord::Migration
  def change
    create_table :verified_names do |t|
      t.string :username
      t.boolean :status

      t.timestamps
    end
  end
end
