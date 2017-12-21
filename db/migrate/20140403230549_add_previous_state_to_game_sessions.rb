class AddPreviousStateToGameSessions < ActiveRecord::Migration
  def change
    add_column :game_sessions, :previous_state, :text
  end
end
