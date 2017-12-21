require "support"
class Player < ActiveRecord::Base
  extend Support
  belongs_to :game_session
  
  validates :money, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :name, :presence => true
  
  def self.find_with_name(game_id, name)
    return Player.where('game_session_id = ? and lower(name) = ?', game_id, name).take
  end
  
  def self.from_option(game, option)
    if numeric?(option)
      player = game.players[option.to_i - 1]
    else
      player = Player.find_with_name(game.id, option)
    end
    raise Exception.new("No Player with that identifier exists: #{option}") if player.nil?
    return player
  end
  
  def css_color
    game = GameSession.find(read_attribute(:game_session_id))
    index = game.players.index {|p| p.id == read_attribute(:id)}
    case index
    when 0
      return "#222"
    when 1
      return "#226"
    when 2
      return "#622"
    when 3
      return "#262"
    when 4
      return "#662"
    when 5
      return "#626"
    else
      return "#FFF"
    end
  end
end
