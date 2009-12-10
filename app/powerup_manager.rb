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
        r = 1.0 / 4
        
        if rand < r
            return RocketJuice
        end

        if rand < r
            return QuantumEngine
        end

        if rand < r
            return Shield
        end

        if rand < r
            return Flame
        end

        if rand < r
            return Freeze
        end

        if rand < r
            return Cloaking
        end
        

        RocketJuice
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
