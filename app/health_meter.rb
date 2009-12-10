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
        health = 0.0 if health < 0
        health = 1.0 if health > 1
        
        @img.rect 1, 1, @img.width - 2, @img.height - 2,  :fill => true, :color => :alpha

        c = []

        # interpolate between green and red to indicate health status
        (0..2).each { |i|
            c[i] = health * Green[i] + (1 - health) * Red[i]
        }
        c[3] = 1.0

        @img.rect 1, 1, 1 + (@img.width - 3) * health, @img.height - 2,  :fill => true, :color => c
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

