class PowerUpManager
  def initialize(window, playgame)
    @window = window
    @playgame = playgame
    @difficulty = @playgame.difficulty
    @powerups = []
  end

  def reset
    @powerups = []
    self
  end

  def add_powerup(options = {})
    @powerups << random_powerup.new(Win, @playgame, options[:x], options[:y])
  end

  def random_powerup
    case rand(100)
    when (0..50)
       [RocketJuice, HealthPack].random
    when (5..60)
      QuantumEngine
    when (60..70)
       Shield
    when (70..80)
       Flame
    when (80..90)
       Freeze
    when (90..100)
      Cloaking
    else
      [RocketJuice, HealthPack].random
    end
  end

  def update
    @powerups.delete_if { |powerup|
      powerup.update == false
    }
  end

  def draw
    @powerups.each {  |powerup|
      powerup.draw
    }
  end
end    
