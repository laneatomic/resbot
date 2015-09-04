# Resistance game logic
class ResistanceGame
  def initialize

    @mission_size = [
      [2, 3, 2, 3, 3], # 5 players
      [2, 3, 4, 3, 4], # 6 players
      [2, 3, 3, 4, 4], # 7 players
      [3, 4, 4, 5, 5], # 8 players
      [3, 4, 4, 5, 6], # 9 players
      [3, 4, 4, 5, 6]  # 10 players
    ]

    @total_spies = [2, 2, 3, 3, 3, 4]

    # Settings
    # TODO: Create settings

    # Game runnings
    @phase = nil
    @running = nil
    @curr_round = 0

    # Player arrays/vars
    @players = []
    @spies = []
    @original_spies = []
    @mission_team = []
    @messenger = nil

    # Voting
    @votes = {}
    @mission_votes = {}
  end

  def _reset_game
    # Game runnings
    @phase = nil
    @running = false
    @curr_round = 0

    # Player arrays/vars
    @players = []
    @spies = []
    @original_spies = []
    @mission_team = []
    @messenger = nil

    # Voting
    @votes = {}
    @mission_votes = {}
  end

  def player?(nick)
    @players.include?(nick)
  end

  def spy?(nick)
    @original_spies.include?(nick)
  end

  def add_player(nick)
    @players << nick unless @players.include?(nick) || @running
  end

  def del_player(nick)
    return unless @players.include?(nick)
    @players.delete(nick)
    @spies.delete(nick) if @original_spies.delete(nick)
    _stop if @players.empty?
  end

  def rename_player(old_nick, new_nick)
    # If a player changes nicks during the game update the running game
    return unless @players.include?(old_nick)

    @players[@players.index(old_nick)] = new_nick
    @leader = new_nick if @leader == old_nick

    @spies[@spies.index(old_nick)] = new_nick if @spies.include?(old_nick)
    @original_spies[@original_spies.index(old_nick)] = new_nick if @original_spies.include?(old_nick)

    @votes[new_nick] = @votes.delete(old_nick)
    @mission_votes[new_nick] = @mission_votes.delete(old_nick) if @mission_votes.key?(old_nick)
  end

  def start
    # return if @running || @players.count < 5
    return if @running # debug only - see previous commented line
    _choose_spies
    _choose_leader

    @phase = :choose_team
    @running = true
  end

  def _stop
    _reset_game
  end

  def _calc_team_size
    i = @players.length - 5
    i = 0 if i < 0
    @mission_size[i][@curr_round]
  end

  def _choose_spies
    i = @players.length - 5
    i = 0 if i < 0
    @spies = @original_spies = @players.sample(@total_spies[i])
  end

  def _choose_leader
    @leader = @players.sample
  end

  def choose_team
    
  end

  def players
    @players
  end

  def spies
    @original_spies
  end

  def current_spies
    @spies
  end

  def score
  end

  def check_game_over
    @resistance_rounds >= 3
  end
end
