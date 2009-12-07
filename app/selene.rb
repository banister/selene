require 'rubygems'
require 'texplay'
require 'common'
require 'matrix'
require 'map'
require 'powerups'
require 'powerup_manager'
require 'turret'
require 'turret_manager'
require 'meteor'
require 'meteor_manager'
require 'platform'
require 'platform_manager'
require 'astronaut'
require 'astronaut_manager'
require 'lander'
require 'particle'
require 'difficulty'
require 'playgame'
require 'getready'
require 'devil/gosu'


class W < Gosu::Window
    attr_accessor :screen_x, :screen_y
    
    def initialize
        super(Map::WIDTH, Map::HEIGHT, false, 20)
        
        # starting level
        @level = 10

        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

        @state = GetReady.new(self, @level)
        @frame_counter = FPSCounter.new

        @screen_x = @screen_y = 0
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
            screenshot.save("selene.jpg", :quality => 80)
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

        
