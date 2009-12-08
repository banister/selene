class MeteorManager

    attr_accessor :frequency
    
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @frequency = @playgame.difficulty.meteor_factor
        @meteors =[]
    end

    def reset
        @meteors = []
        self
    end

    def each(&block)
        @meteors.each &block
    end

    def find(&block)
        @meteors.find &block
    end

    def add_and_randomize(number)
        number.times { 
            create_meteor(@playgame.map.total_map_width * rand, 700 * rand)
        }
        self
    end

    def move_meteors_by(dx, dy)
        @meteors.each { |v| 
            v.warp(v.x + dx, v.y + dy)
        }
        self
    end

    def create_meteor(x, y)
            big_meteor_factor = 0.1 +
                @playgame.level / 100.0

            big_meteor_factor = 0.6 if big_meteor_factor > 0.6
            
            if rand < big_meteor_factor
                @meteors << LargeMeteor.new(@window, @playgame, x, y)
            else
                @meteors << SmallMeteor.new(@window, @playgame, x, y)
            end
    end

    def update
        @meteors.delete_if { |m|
            m.update == false
        }
        
        if rand < @frequency
            create_meteor(@playgame.map.total_map_width * rand, - 20)
        end
    end

    def draw
        @meteors.each { |m|
            m.draw
        }
    end
end
