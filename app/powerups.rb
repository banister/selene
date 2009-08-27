# powerup abstract base class
class PowerUp
    include BoundingBox
    include Tasks
    
    CUR_DIREC = File.dirname(__FILE__)   

    TIMEOUT = 15

    def initialize(window, playgame, x, y)
        @x, @y = x, y
        @y_anchor = @y
        @playgame = playgame
        @window = window

        @pickup_sound ||= Gosu::Sample.new(@window, "#{CUR_DIREC}/media/powerup.ogg")
        @pickup_sound_vol = 1.0
        
        # define configure method in subclasses
        configure

        set_bounding_box(@image.width, @image.height)

        @theta = rand(360)
        @dtheta = rand(2) == 0 ? -1 : 1

        new_task(:wait => TIMEOUT, :name => :timeout) { @fade_out = true }
        
        @color = Gosu::Color.new(255, 255, 255, 255)
    end

    def set_image(image)
        @image = image
    end

    def set_pickup_sound(sound, vol=1)
        @pickup_sound_vol = vol
        @pickup_sound = sound
    end

    def action(&block)
        @action_lambda = block
    end

    def update
        check_tasks
        
        if intersect?(@playgame.lander)
            @action_lambda.call
            @pickup_sound.play(@pickup_sound_vol)
            false
        elsif @color.alpha <= 0
            false
        else
            true
        end
    end

    def draw
        @color.alpha -=5 if @fade_out
        @theta += @dtheta
        @y = @y_anchor + 2 * Math::sin(@theta * 10 * Math::PI / 180)
        @image.draw_rot(@x, @y, 0, 0, 0.5, 0.5, 1, 1, @color)
    end
end

## powerups ##
class RocketJuice < PowerUp
    def configure
        set_image Gosu::Image.new(@window, "#{CUR_DIREC}/media/rockjuice.png")

        action { @playgame.lander.refuel }
    end
end

class QuantumEngine < PowerUp
    def configure
        set_image Gosu::Image.new(@window, "#{CUR_DIREC}/media/quantum.png")

        action { @playgame.lander.got_quantum_engine }
    end

    # this implements the 'quantum engine'
    module PrecisionControl
        def handle_controls
            super
            
            @da += 0.001 if @window.button_down? Gosu::KbNumpadAdd
            @da -= 0.001 if @window.button_down? Gosu::KbNumpadSubtract

            @da = 0 if @da < 0 
        end
    end
end

class Shield < PowerUp
    def configure
        set_image Gosu::Image.new(@window, "#{CUR_DIREC}/media/shield.png")
        action { @playgame.lander.got_shield }
    end
end

class Freeze < PowerUp
    def configure
        set_image Gosu::Image.new(@window, "#{CUR_DIREC}/media/freeze.png")
        set_pickup_sound Gosu::Sample.new(@window, "#{CUR_DIREC}/media/freeze.ogg")
        action { @playgame.freeze_movement }
    end
end

## end powerups ##
