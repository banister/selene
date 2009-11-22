class MeteorManager

    attr_accessor :frequency
    
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @frequency = @playgame.difficulty.meteor_factor
    end

    def reset
        @playgame.objects.delete_if { |v| v.is_a?(Meteor) }
        self
    end

    def add_and_randomize(number)
        number.times { 
            create_meteor(Map::WIDTH * rand, 700 * rand)
        }
        self
    end

    def move_meteors_by(dx, dy)
        @playgame.objects.each { |v| 
            v.warp(v.x + dx, v.y + dy) if v.is_a?(Meteor)
        }
        self
    end

    def create_meteor(x, y)
            big_meteor_factor = 0.1 +
                @playgame.level / 100.0

            big_meteor_factor = 0.6 if big_meteor_factor > 0.6
            
            if rand < big_meteor_factor
                @playgame.objects << LargeMeteor.new(@window, @playgame, x, y)
            else
                @playgame.objects << SmallMeteor.new(@window, @playgame, x, y)
            end
    end
    
    def update
        if rand < @frequency
            create_meteor(Map::WIDTH * rand, - 20)
        end
    end
end
