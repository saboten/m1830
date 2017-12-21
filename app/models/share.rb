class Share < ActiveRecord::Base
  belongs_to :game_session
  
  def owner_string
    if read_attribute(:player_id) > 0
      return "#{Player.find(read_attribute(:player_id)).name}: #{read_attribute(:quantity)}"
    else
      return "#{Corporation.find(read_attribute(:corporation_id)).print_initials}: #{read_attribute(:quantity)}"
    end
  end
  
  def css_color
    if read_attribute(:player_id) > 0
      return Player.find(read_attribute(:player_id)).css_color
    else
      return Corporation.find(read_attribute(:corporation_id)).css_color('color-primary')
    end
  end
  
end
