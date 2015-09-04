# Timer is needed to time rounds.
# At the end of every round, check game win/lose conditions.

require 'cinch'
require_relative 'resistance/resistance_game.rb'

# A game of Resistance
class Resistance
  include Cinch::Plugin

  def initialize(*args)
    # This is required by Cinch::Plugin
    super

    # My own stuff
    @game = ResistanceGame.new
    @running = false
  end

  # commands for gameplay
  set :prefix, /^!resistance /

  listen_to :nick, method: :nick_change

  match /new$/, method: :new_game
  match /join$/, method: :join
  match /quit$/, method: :quit
  match /start$/, method: :start
  match /fstop$/, method: :stop
  match /players$/, method: :players

  # query-only commands
  match /vote$/, react_on: :private, method: :vote, use_prefix: false
  match /sabotage$/, react_on: :private, method: :sabotage, use_prefix: false
  match /finish$/, react_on: :private, method: :finish, use_prefix: false

  def nick_change(m)
    old_nick = m.prefix.split('!', 2)[0]
    puts old_nick
    @game.rename_player(old_nick, m.user.nick)
  end

  def new_game(m)
    if @running
      m.reply 'A game of resistance is already started. Please join the one in progress!'
    else
      m.reply "#{m.user.nick} has started a new game of resistance! Use '!resistance join' to join!"
      @running = true
    end
  end

  def join(m)
    new_game(m) if @game.players.empty?
    m.reply "#{m.user.nick} has joined the game of Resistance!" if @game.add_player(m.user.nick)
  end

  def quit(m)
    return unless @game.player?(m.user.nick)
    spy = @game.spy?(m.user.nick)
    @game.del_player(m.user.nick)
    if spy
      m.reply "#{m.user.nick} was confirmed as an Imperial Spy, and was summarily executed. (User quit the game)"
    else
      m.reply "#{m.user.nick} was found by the Imperials, and was summarily tortured to death. (User quit the game)"
    end
  end

  def start(m)
    m.channel.moderated = true
    @game.start

    @game.players.each do |player|
      m.channel.voice(player)
      User(player).send('You are a member of the Resistance!') unless @game.spy?(player)
    end

    @game.spies.each do |spy|
      User(spy).send('You are an Imperial Spy!')
      User(spy).send("Your team consists of: #{@game.spies.join(', ')}")
    end

    m.reply 'The game of Resistance has started!'
  end

  def stop(m)
    m.channel.moderated = false

    @game.players.each do |player|
      m.channel.devoice(player)
    end

    @game._stop
    @running = false
    m.reply 'The game of Resistance has been stopped!'
  end

  def players(m)
    m.reply "There are #{@game.players.length} players: #{@game.players.join(', ')}"
  end

  def game_over(m)
    # If @game.check_game_over == true, resistance won. Otherwise, spies won.
  end

  def score(m)
  end
end
