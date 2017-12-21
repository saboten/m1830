class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.integer :player_id, :corporation_id, :quantity
      t.belongs_to :game_session
      t.timestamps
    end
  end
end
