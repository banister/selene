class AstronautManager
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @astronauts = []
    end

    def add_astronaut(options = {})
        astro = Astronaut.new(@window, @playgame, options[:screen], options[:x], options[:y])
        astro.set_into_place
        @astronauts << astro
    end
    
    def reset
        @playgame.objects.delete_if { |v| v.is_a?(Astronaut) }
        self
    end

    def screen_is(screen)
        @playgame.objects.delete_if { |v|
            v.is_a?(Astronaut) && v.screen != screen
        }

        @playgame.objects += @astronauts.select { |v| v.screen == screen }
    end

    def update
        @astronauts.delete_if { |astro|
            if astro.screen == @playgame.map.current_screen_index
                astro.update == false
            end
        }
    end

    def draw
        @astronauts.each { |astro|
            if astro.screen == @playgame.map.current_screen_index
                astro.draw
            end
        }
            
    end
end    
