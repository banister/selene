class Difficulty

  FPS_FACTOR = 1 / 50.0

  class << self
    def set_playgame(pg)
      @playgame = pg
    end

    def level_error
        raise "Invalid level. Got #{@playgame.level}"
    end
    
    def meteor_factor
      return 0 if @playgame.is_movement_frozen?
      
      meteor_frequency = FPS_FACTOR / 2 + @playgame.level / 1000.0

      meteor_frequency > FPS_FACTOR ? FPS_FACTOR : meteor_frequency
    end

    def wind_velocity
      wx = rand * PlayGame::Wind_Velocity - PlayGame::Wind_Velocity / 2
      wy = rand * PlayGame::Wind_Velocity - PlayGame::Wind_Velocity / 2

      if @playgame.level > 20 
        factor = 1 + 0.2 * (@playgame.level - 20)
        factor = 8 if factor > 8
        wx *= factor
        wy *= factor
      end
      
      [wx, wy]
    end

    def num_turrets
      case @playgame.level
      when (0..5)
        num_screens
      when (5..10)
        (num_screens * 1.5).to_int
      when (10..15)
        num_screens * 2
      when (15..25)
        num_screens * 3
      when (25..Float::INFINITY)
        (num_screens * 3 + (@playgame.level - 25)).to_int
      else
        level_error
      end
    end

    def num_astronauts
      case @playgame.level
      when (0..5)
        3
      when (5..13)
        4
      when (13..25)
        5
      when (25..Float::INFINITY)
        (5 + (@playgame.level - 25) * 0.2).to_int
      else
        level_error
      end
    end

    def num_platforms
      case @playgame.level
      when (0..5)
        [1, 1, 1, 0]
      when (5..13)
        a = [1, 1, 1, 0]

        2.times do |v|
          a[rand(a.size)] += 1
        end
        a
      when (13..20)
        a = [1, 1, 1, 0]

        3.times do |v|
          a[rand(a.size)] += 1
        end
        a
      when (20..30)
        a = [1, 1, 1, 0]

        4.times do |v|
          a[rand(a.size)] += 1
        end
        a
      when (30..Float::INFINITY)
        a = [1, 1, 1, 0]

        extra_plats = ((@playgame.level - 30) * 0.4).to_int
        extra_plats.times do
          a[rand(a.size)] += 1
        end
        a
      else
        level_error
      end
    end

    def num_screens
      case @playgame.level
      when (0..3)
        1
      when (3..5)
        2
      when (5..13)
        3
      when (13..20)
        4
      when (20..30)
        5
      when (30..Float::INFINITY)
        (5 + (@playgame.level - 30) * 0.1).to_int
      else
        level_error
      end
    end
  end
  
end
