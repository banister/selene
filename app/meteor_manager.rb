class MeteorManager
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @difficulty = @playgame.difficulty
    end
    
    def update
        if rand < @difficulty.meteor_factor
            big_meteor_factor = 0.1 +
                @playgame.level / 200.0

            big_meteor_factor = 0.6 if big_meteor_factor > 0.6
            
            if rand < big_meteor_factor
                @playgame.objects << LargeMeteor.new(@window, @playgame, 1024 * rand, -20)
            else
                @playgame.objects << SmallMeteor.new(@window, @playgame, 1024 * rand, -20)
            end
        end
    end
end
