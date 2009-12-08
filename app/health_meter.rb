class HealthMeter
    include TexPlay::Colors
    
    def initialize(width = 50, height = 6)
        @width, @height = width, height
        @img = TexPlay::create_blank_image(Win, width, height).
            rect(0, 0, width - 1, height - 1).
            fill(1, 1, :color => :green)
    end

    # health must between 0 and 1.0
    def update_health_status(health)
        return if health < 0
        
        c = []

        # interpolate between green and red to indicate health status
        (0..2).each { |i|
            c[i] = health * Green[i] + (1 - health) * Red[i]
        }
        c[3] = 1.0

        @img.fill(1, 1, :color => c)
        @img.rect 1 + (@width - 3) * health, 1, @width - 2, @height - 2, :fill => true,
        :color => :alpha
    end

    def draw(*args)
        @img.draw(*args)
    end

    def draw_rot(*args)
        @img.draw_rot(*args)
    end

    def sdraw(*args)
        @img.sdraw(*args)
    end

    def sdraw_rot(*args)
        @img.sdraw_rot(*args)
    end
end

