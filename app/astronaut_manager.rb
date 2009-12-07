class AstronautManager
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @astronauts = []
    end

    def add_astronaut(options = {})
        astro = Astronaut.new(@window, @playgame, options[:x], options[:y])
        astro.set_into_place
        @astronauts << astro
    end
    
    def reset
        @astronauts = []
        self
    end

    def update
        @astronauts.delete_if { |astro|
            astro.update == false
        }
    end

    def draw
        @astronauts.each { |astro|
                astro.draw
        }
    end
end    
