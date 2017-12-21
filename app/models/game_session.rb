class GameSession < ActiveRecord::Base
  has_many :corporations, :dependent => :destroy
  has_many :players, :dependent => :destroy
  accepts_nested_attributes_for :players, :reject_if => lambda { |p| p[:name].blank? }, :allow_destroy => true
  validate :player_number
  has_many :shares
  serialize :companies
  serialize :previous_state
  
  companies = {}
  Dir.glob("#{Rails.root}/data/companies/*.yml") do |yml|
    companies.merge!(YAML.load_file(yml))
  end
  COMPANIES = companies
  
  def self.companies(game = M1830::Application.config.game)
    return COMPANIES[game]
  end
  
  def self.company_name(initials)
    raise Exception.new("Invalid company initials: #{initials}") if !companies.key?(initials)
    return GameSession.companies[initials]["name"]
  end
  
  def company_owner(initials)
    companies = read_attribute(:companies)
    raise Exception.new("Invalid company initials: #{initials}") if !companies.key?(initials)
    if companies[initials][:removed]
      return nil
    else
      return companies[initials][:owner_type].constantize.find(companies[initials][:owner_id])
    end
  end
      
  def company_owner_name(initials)
    companies = read_attribute(:companies)
    raise Exception.new("Invalid company initials: #{initials}") if !companies.key?(initials)
    if companies[initials][:removed]
      return "None"
    else
      return company_owner(initials).name
    end
  end
  
  def bank_remaining
    outstanding_money = 0
    Corporation.where('game_session_id = ?', read_attribute(:id)).each {|c| outstanding_money += c.money}
    Player.where('game_session_id = ?', read_attribute(:id)).each {|p| outstanding_money += p.money}
    return read_attribute(:bank) - outstanding_money
  end
  
  private
  
  def player_number
    if players.reject(&:marked_for_destruction?).length < 3
      errors.add(:base, "Game must have at least three players")
    end
  end
end
