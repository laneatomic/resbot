require 'cinch'

# A game of Mafia
class Mafia
  include Cinch::Plugin

  def initialize(*args)
    # This is required by Cinch::Plugin
    super

    # My own stuff
    @running = false
    @players = Array.new
  end

  # commands for gameplay
  match /mafia$/, method: :new_game
  match /mafia join$/, method: :join
  match /mafia quit$/, method: :quit
  match /^kill (.+)/, react_on: :private, method: :kill, use_prefix: false
  match /mafia start$/, method: :start

  def new_game(m)
    if @running
      m.reply 'A game of Mafia is already started. Please join the one in progress!'
    else
      m.reply "#{m.user.nick} has started a new game of Mafia! Use '!mafia join' to join!"
      @running = true
    end
  end

  def join(m)
    new_game(m) unless @running
    if !@players.empty? && @players.include?(m.user.nick)
      m.reply "#{m.user.nick}: You are already in the game!"
    else
      m.reply "#{m.user.nick} has joined the game of Mafia!"
      @players << m.user.nick
    end
  end

  def quit(m)
    if !@players.empty? && @players.include?(m.user.nick)
      @players.delete(m.user.nick)
      m.reply "#{m.user.nick} has quit the game of Mafia."
      stop(m) if @players.empty?
    else
      User(m.user).send('You are not in the current game of Mafia!')
    end
  end

  def start(m)
    m.reply 'The game of Mafia has started!'
  end

  def stop(m)
    m.reply 'The game of Mafia has ended!'
  end

  def kill(m, player)
    return unless @running && @night && @mafia.include?(m.player.name)
    m.reply "#{m.user.nick} has killed #{player}!"
  end
end
