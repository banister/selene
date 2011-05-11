require 'pry'
require 'rubygems'
require 'texplay'
require 'common'
require 'matrix'
require 'difficulty'
require 'map'
require 'health_meter'
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
require 'bullet'
require 'lander'
require 'particle'
require 'playgame'
require 'getready'

class W < Gosu::Window
  attr_accessor :screen_x, :screen_y
  
  def initialize
    fullscreen = ARGV[0] ? true : false
    super(Map::WIDTH, Map::HEIGHT, fullscreen)
    
    # starting level
    @level = 5
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @state = GetReady.new(self, @level)
    @frame_counter = FPSCounter.new
    @screen_x = @screen_y = 0
  end

  def update

    # change from 'Get Ready' to playing state
    if (@state.name == :getready) && button_down?(Gosu::KbSpace) 
      if @state.applaud == :failure
        @state = @playgame.tap { |v| v.reset }
      else
        @state = PlayGame.new(self, @level)
      end

      # player succeeds, increment level (and difficulty)
    elsif @state.level_complete?
      @level += 1
      @state = GetReady.new(self, @level, :success)

      # 'S' is the suicide key, restarts level
    elsif @state.level_fail? || button_down?(Gosu::KbS)
      @playgame = @state
      @state = GetReady.new(self, @level, :failure)
    elsif button_down?(Gosu::KbR)
      @state = GetReady.new(self, @level, :restart)
    elsif button_down?(Gosu::KbP)
      binding.pry
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


