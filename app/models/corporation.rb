require "support"
class Corporation < ActiveRecord::Base
  extend Support
  belongs_to :game_sessions
  #TODO Use of default_scope without a block is deprecated. Do this a different way.
  default_scope order('initials DESC')
  validates :money, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :initials, :presence => true
  
  corporations = {}
  Dir.glob("#{Rails.root}/data/corporations/*.yml") do |yml|
    corporations.merge!(YAML.load_file(yml))
  end
  CORPORATIONS = corporations
  
  def self.corporations(game = M1830::Application.config.game)
    return CORPORATIONS[game]
  end
  
  def self.find_with_initials(game_id, initials)
    return Corporation.where('game_session_id = ? and lower(initials) = ?', game_id, initials).take
  end
  
  def self.from_option(id, option)
    if numeric?(option)
      corporation = Corporation.find(option)   
    else
      corporation = Corporation.find_with_initials(id, option)
    end
    raise Exception.new("No Corporation with that identifier exists: #{option}") if corporation.nil?
    return corporation
  end
  
  def shares
    return Share.where('corporation_id = ?', read_attribute(:id))
  end
  
  def floated?
    total_quantity = 0
    Share.where('corporation_id = ?', read_attribute(:id)).each {|s| total_quantity += s.quantity}
    return (total_quantity >= 6)
  end
  
  #TODO Consider refactoring some of this
  def name
    return Corporation.corporations[read_attribute(:initials)]["print_initials"]
  end
  
  def long_name
    return Corporation.corporations[read_attribute(:initials)]["name"]
  end
  
  def print_initials
    return Corporation.corporations[read_attribute(:initials)]["print_initials"]
  end
  
  def css_color(type = "color-primary")
    color_set = Corporation.corporations[read_attribute(:initials)][type]
    return "rgb(#{color_set["r"]},#{color_set["g"]},#{color_set["b"]})"
  end
end
