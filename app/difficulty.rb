class Difficulty

    FPS_FACTOR = 1 / 50.0
    
    def initialize(playgame)
        @playgame = playgame
    end

    def meteor_factor
        return 0 if @playgame.is_movement_frozen?
        
        meteor_frequency = FPS_FACTOR / 2 + @playgame.level / 1000.0

        meteor_frequency > FPS_FACTOR ? FPS_FACTOR : meteor_frequency
    end

    def refuel_factor
        low_fuel_factor = (1 - (@playgame.lander.fuel.to_f / Lander::FUEL)) / 100.0
        low_fuel_factor = if low_fuel_factor > FPS_FACTOR / 3.5 then
                              FPS_FACTOR / 3.5
                          else
                              low_fuel_factor
                          end
        
        FPS_FACTOR / 500.0 + low_fuel_factor
    end

    def shield_factor
        return 0 if @playgame.level < 10

        FPS_FACTOR / 40.0 + (@playgame.level - 10) * (FPS_FACTOR / 300.0)
    end

    def freeze_factor
        return 0 if @playgame.level < 10

        FPS_FACTOR / 40.0 + (@playgame.level - 10) * (FPS_FACTOR / 300.0)
    end

    def quantum_engine_factor
        return 0 if @playgame.level < 10

        FPS_FACTOR / 40.0 + (@playgame.level - 10) * (FPS_FACTOR / 300.0)
    end
end
