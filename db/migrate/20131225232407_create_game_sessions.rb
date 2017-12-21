class CreateGameSessions < ActiveRecord::Migration
  def change
    create_table :game_sessions do |t|
      t.integer :bank
      t.text :companies
      t.timestamps
    end
  end
end
