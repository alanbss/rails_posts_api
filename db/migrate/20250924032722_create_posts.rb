class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :ip, null: false
      t.references :user, null: false, foreign_key: true
      t.decimal :avg_rating, precision: 5, scale: 4, default: 0.0

      t.timestamps
    end
  end
end
