class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.integer :money
      t.belongs_to :game_session
      t.timestamps
    end
  end
end
