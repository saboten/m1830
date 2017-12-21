require 'command_interpreter'
require 'support'
class GameSessionsController < ApplicationController
  extend Support
  helper GameSessionsHelper
  layout 'game_session', only: [:show]
  
  def index
    @games = GameSession.all
  end
  
  def new
    @game = GameSession.new
    @new_player = Player.new
  end
  
  def create
    @game = GameSession.new(params.require(:game_session).permit(:id, :bank, players_attributes: [:id, :name, :money]))
    @game.companies = {}
    unless @game.save
      render action: 'new'
      return
    end
    GameSession.companies.each do |key, value|
      if value["core"] == true
        owner_id = @game.players[params[:company_owner][key].to_i].id
        @game.companies[key] = {owner_type: "Player", owner_id: owner_id, removed: false}
      end
    end 
    params[:company].each do |key, value|
      if value == "1"
        owner_id = @game.players[params[:company_owner][key].to_i].id
        @game.companies[key] = {owner_type: "Player", owner_id: owner_id, removed: false}
      end
    end
    Corporation.corporations.each do |key, value|
      if value["core"] == true
        @game.corporations.push(Corporation.new(initials: key, money: 0))
      end
    end
    params[:corporation].each do |key, value|
      if value == "1"
        @game.corporations.push(Corporation.new(initials: key, money: 0))
      end
    end
    @game.corporations.each do |c|
      @game.shares.push(Share.new(player_id: 0, corporation_id: c.id, quantity: 0))
      @game.players.each do |p|
        @game.shares.push(Share.new(player_id: p.id, corporation_id: c.id, quantity: 0))
      end
    end
    @game.previous_state = init_previous_state
    #TODO Move this into a more generic method for evaluating game-specific rules.
    ca_share = Share.find_by(player_id: @game.companies["ca"][:owner_id], corporation_id: Corporation.find_with_initials(@game,"prr").id)
    add_share(ca_share, 1)
    bo_share = Share.find_by(player_id: @game.companies["bo"][:owner_id], corporation_id: Corporation.find_with_initials(@game,"bo").id)
    add_share(bo_share, 2)
    if @game.save
      redirect_to root_path
    else
      @game.destroy
      flash[:error] = "Something went wrong while creating the private company table"
      redirect_to root_path
    end
  end
  
  def assign_companies
    @game = GameSession.find(params[:id])
  end
  
  def show
    @game = GameSession.find(params[:id])
    @money_change = Hash.new({})
    @title = "1830 Manager"
    #TODO Add game-not-found code here
  end
  
  def destroy
    @game = GameSession.find(params[:id])
    @game.destroy
    flash[:notice] = "Successfully removed game session"
    redirect_to root_path
  end
  
  def help
    
  end
  
  def settings
    
  end
  
  def final_score
    @game = GameSession.find(params[:id])
    @money_change = Hash.new({})
    share_values = Hash[params[:share_values].map{ |k, v| [k.to_i, v.to_i] }] 
    scores = Array.new
    @game.players.each do |p|
      score = p.money
      shares = Share.where(player_id: p.id)
      shares.each {|s| score += s.quantity * share_values[s.corporation_id]}
      scores.push({name: p.name, score: score})
    end
    scores.sort! {|x,y| y[:score] <=> x[:score]}
    results_string = "<b>Final Results</b><br />"
    scores.each {|s| results_string += "#{s[:name]}: #{s[:score]}<br />"}
    flash[:notice] = results_string
    render :show, layout: false
  end
  
  def command
    @game = GameSession.find(params[:id])
    @money_change = Hash.new({})
    begin
      command = CommandInterpreter.new(params[:command])
      @game.previous_state = init_previous_state unless command.action == :undo
      case command.action
      when :add, :sub
        flash[:notice] = parse_add_subract(command)
      when :company_payout
        #Income is added to this hash before being added to players/corps so that @money_change stores an accurate value
        income = Hash.new(0)
        @game.companies.each do |key, value|
          unless value[:removed]
            target = value[:owner_type].constantize.find(value[:owner_id])
            income[target] += GameSession.companies[key]["revenue"]
          end
        end
        income.each_pair {|target,value| add_money(target, value)}
        flash[:notice] = "Private Companies paid income"    
      when :run
        flash[:notice] = parse_run(command)
      when :sell_company
        flash[:notice] = parse_sell_company(command)
      when :buy, :sell
        flash[:notice] = parse_buy_sell(command)
      when :remove
        @game.previous_state[:companies] = @game.companies
        @game.save!
        @game.companies[command.value][:removed] = true
        @game.save!
        flash[:notice] = "#{GameSession.company_name(command.value)} removed from the game"
      when :undo
        restore_state
        flash[:notice] = "State restored"    
      end
    rescue Exception => e
      flash[:error] = e.message
    end
    @game.save! if ![:sell_company, :remove, :undo].include?(command.action)
    render :show, layout: false
  end
  
  private
  
  def parse_add_subract(command)
    value = command.value.to_i || 1
    options = command.options
    if command.action == :sub
      results_string = "Subtracted #{value}"
      value = -value
    else
      results_string = "Added #{value}"
    end
    if(options.key?(:p))
      target = Player.from_option(@game,options[:p])
    else
      target = Corporation.from_option(@game.id,options[:c])
    end
    if(options.key?(:s))
      player_id = target.class == Player ? target.id : 0
      share_corp = Corporation.from_option(@game.id, options[:s])
      share = Share.find_by(player_id: player_id, corporation_id: share_corp.id)
      add_share(share,value, false, true)
      results_string += " shares of #{share_corp.name}. Target: #{target.name}"
    else
      add_money(target, value)
      results_string += " dollars. Target: #{target.name}"
    end
    return results_string
  end
  
  def parse_buy_sell(command)
    options = command.options
    player = Player.from_option(@game,options[:p])
    corporation = Corporation.from_option(@game.id,options[:s])
    quantity = options[:q] || 1
    if command.action == :sell
      results_string = "Sold #{quantity}"
      quantity = -quantity
    else
      results_string = "Bought #{quantity}"
    end
    share = Share.find_by(player_id: player.id, corporation_id: corporation.id)
    add_share(share, quantity, options[:b], false)
    add_money(player, -(options[:v] * quantity))
    results_string += " share of #{corporation.name} for #{options[:v]} apiece"
    results_string += " from the bank pool" if options[:b]
    results_string += "<br />Target: #{player.name}"
    return results_string
  end
  
  def parse_run(command)
    options = command.options
    corporation = Corporation.from_option(@game.id, command.value)
    @game.previous_state[:corporation_income][corporation.id] = corporation.income
    corporation.income = options[:v]
    corporation.save!
    results_string = "Ran trains belonging to #{corporation.name} valued at #{options[:v]}<br />"
    if(options[:w])
      add_money(corporation, options[:v])
      results_string += "Withheld money"
    else
      per_share_income = options[:v] / 10
      shares = Share.where(corporation_id: corporation.id)
      results_string += "Paid out:"
      shares.each do |s|
        if s.quantity > 0
          if s.player_id == 0
            add_money(corporation, per_share_income * s.quantity)
            results_string += "<br />#{corporation.name}: #{per_share_income * s.quantity}"
          else
            player = Player.find(s.player_id)
            add_money(player, per_share_income * s.quantity)
            results_string += "<br />#{player.name}: #{per_share_income * s.quantity}"
          end
        end
      end
    end
    return results_string
  end
  
  def parse_sell_company(command)
    current_owner = @game.company_owner(command.value)
    options = command.options
    if(options.key?(:p))
      target = Player.from_option(@game,options[:p])
    else
      target = Corporation.from_option(@game.id,options[:c])
    end
    add_money(current_owner, options[:v])
    add_money(target, -options[:v])
    @game.previous_state[:companies] = @game.companies
    @game.save!
    @game.companies[command.value][:owner_type] = target.class.to_s
    @game.companies[command.value][:owner_id] = target.id
    @game.save!
    return "Sold #{GameSession.company_name(command.value)} to #{target.name} for $#{options[:v]}"
  end
  
  def add_money(target, amount)
    if target.class == Player
      @game.previous_state[:player_money][target.id] = target.money
    else
      @game.previous_state[:corporation_money][target.id] = target.money
    end
    target.money += amount
    target.save
    @money_change[target] = {change: amount}
  end
  
  def add_share(target, amount, add_from_bank_pool = false, sell_into_initial_offering = false)
    raise Exception.new("You may not sell more shares than you own: Player shares: #{target.quantity}, Shares sold: #{amount.abs}") if target.quantity + amount < 0
    shares = Share.where(corporation_id: target.corporation_id)
    bank_share = Share.find_by(player_id: 0, corporation_id: target.corporation_id)
    total_shares_in_play = 0
    shares.each do |s|
      total_shares_in_play += s.quantity
    end
    if(total_shares_in_play + amount > 10 and !add_from_bank_pool)
      if bank_share.quantity > 0
        raise Exception.new("Shares must be purchased from the bank pool: limit(#{bank_share.quantity})")
      else
        raise Exception.new("There are not enough available shares in the game to process this transaction.")
      end
    elsif(bank_share.quantity == 0 and add_from_bank_pool == true)
      raise Exception.new("You can't buy shares from the bank because the bank is empty")
    else
      if(add_from_bank_pool or (amount < 0 and !sell_into_initial_offering))
        @game.previous_state[:share_quantity][bank_share.id] = bank_share.quantity
        bank_share.quantity -= amount
        bank_share.save!
      end
      @game.previous_state[:share_quantity][target.id] = target.quantity
      target.quantity += amount
      target.save!
    end
  end
  
  def init_previous_state
    return {player_money: Hash.new, 
            corporation_money: Hash.new,
            corporation_income: Hash.new, 
            share_quantity: Hash.new}
  end
  
  def restore_state
    @game.previous_state[:player_money].each_pair {|k,v| Player.find(k).update(money: v)}
    @game.previous_state[:corporation_money].each_pair {|k,v| Corporation.find(k).update(money: v)}
    @game.previous_state[:corporation_income].each_pair {|k,v| Corporation.find(k).update(income: v)}
    @game.previous_state[:share_quantity].each_pair {|k,v| Share.find(k).update(quantity: v)}
    if @game.previous_state.key?(:companies)
      @game.companies = @game.previous_state[:companies]
      @game.save!
    end
  end
  
end
