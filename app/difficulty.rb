class IncrementalDifficulty

    FPS_FACTOR = 1 / 50.0
    
    def initialize(playgame)
        @playgame = playgame
    end

    def meteor_frequency
        #        0.008 + @playgame.level / 1000.0
        FPS_FACTOR
    end

    def refuel_frequency
    end
    
end
