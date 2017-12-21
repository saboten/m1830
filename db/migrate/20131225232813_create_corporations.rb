class CreateCorporations < ActiveRecord::Migration
  def change
    create_table :corporations do |t|
      t.belongs_to :game_session
      t.integer :money, :income
      t.string :initials
      t.timestamps
    end
  end
end
