require 'rubygems'
require 'texplay'
require 'common'
require 'map'
require 'powerups'
require 'powerup_manager'
require 'meteor'
require 'meteor_manager'
require 'platform'
require 'platform_manager'
require 'lander'
require 'particle'
require 'difficulty'
require 'playgame'
require 'getready'


class W < Gosu::Window
    def initialize
        super(1024, 768, false, 20)
        
        # starting level
        @level = 10

        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

        @state = GetReady.new(self, @level)
        @frame_counter = FPSCounter.new
    end

    def update

        # change from 'Get Ready' to playing state
        if (@state.name == :getready) && button_down?(Gosu::KbSpace) 
            @state = PlayGame.new(self, @level)

        # player succeeds, increment level (and difficulty)
        elsif @state.level_complete?
            @level += 1
            @state = GetReady.new(self, @level, :success)

        # 'S' is the suicide key, restarts level
        elsif @state.level_fail? || button_down?(Gosu::KbS)
            @state = GetReady.new(self, @level, :failure)

        elsif button_down?(Gosu::KbEscape)
            exit
        end

        @state.update
        @frame_counter.register_tick
    end
    
    def draw
        @state.draw
        @font.draw("FPS: #{@frame_counter.fps}",
                   10, 10, 3, 1.0, 1.0, 0xffffff00)
        
    end
end

Win = W.new
Win.show

        
