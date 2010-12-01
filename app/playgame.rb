class PlayGame
  include Tasks
  
  attr_accessor :objects
  attr_reader :map, :lander, :platform_manager, :meteor_manager, :turret_manager
  attr_reader :level, :wind, :difficulty, :powerup_manager
  
  Gravity = 0.002
  LandGravity = 0.1
  Wind_Velocity = 0.005
  FREEZE_MOVEMENT_TIMEOUT = 20

  def initialize(window, level)
    Difficulty.set_playgame(self)
    @window = window
    @level_complete = false
    @level_fail = false
    @level = level
    @freeze_movement = false
    @map = Map.new(@window)
    @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)

    @triumph_sound = Gosu::Sample.new(@window, "#{MEDIA}/triumph.ogg")
    @crash_sound = Gosu::Sample.new(@window, "#{MEDIA}/smash.ogg")

    @wind = Array.new(2)
    @wind.first, @wind.last = Difficulty.wind_velocity

    @objects = []
    @lander = Lander.new(@window, self)
    Win.screen_x = 0

    @meteor_manager = MeteorManager.new(@window, self)
    @turret_manager = TurretManager.new(@window, self)

    @powerup_manager = PowerUpManager.new(@window, self)
    @platform_manager = PlatformManager.new(@window, self)
    @astronaut_manager = AstronautManager.new(@window, self)

    @objects.push @astronaut_manager, @platform_manager, @meteor_manager, @turret_manager, @powerup_manager

    place_platforms
    place_astronauts
    place_turrets
  end

  def reset
    @lander.reset
    @level_fail = false
    @level_complete = false
    Win.screen_x = 0
  end

  def place_platforms
    num_red, num_green, num_blue, num_yellow = Difficulty.num_platforms
    
    # Red platform
    num_red.times do
      @platform_manager.add_platform :type => RedPlatform,
      :x => rand(@map.total_map_width), :y => 100
    end

    # Green platform
    num_green.times do
      @platform_manager.add_platform :type => GreenPlatform,
      :x => rand(@map.total_map_width), :y => 100
    end
    
    # Blue platform
    num_blue.times do
      @platform_manager.add_platform :type => BluePlatform,
      :x => rand(@map.total_map_width), :y => 100
    end

    # Yellow platform
    num_yellow.times do
      @platform_manager.add_platform :type => YellowPlatform,
      :x => rand(@map.total_map_width), :y => 100
    end
  end

  def place_astronauts
    Difficulty.num_astronauts.times { 
      @astronaut_manager.add_astronaut :x => rand(@map.total_map_width), :y => 100
    }
  end

  def place_turrets
    Difficulty.num_turrets.times { 
      @turret_manager.add_turret :x => rand(@map.total_map_width), :y => 100
    }
  end

  def freeze_movement
    @freeze_movement = true

    # unfreeze movement in FREEZE_MOVEMENT_TIMEOUT seconds
    after(FREEZE_MOVEMENT_TIMEOUT, :name => :freeze_timeout) {
      @freeze_movement = false
    }
  end

  def is_movement_frozen?
    @freeze_movement
  end

  def update
    check_tasks
    
    @lander.update
    @objects.reject! { |m| m.update == false }

    if @lander.safe_astronaut_count == Difficulty.num_astronauts 
      @triumph_sound.play(1.0)
      @level_complete = true
    elsif !@lander.active then
      @crash_sound.play(1.0)
      @level_fail = true
    end
  end
  
  def draw
    @map.draw
    @lander.draw
    @objects.each(&:draw)

    @font.draw("astronaut count: #{@lander.astronaut_count}", 340, 10, 3, 1.0, 1.0,
               0xffffff00)
    @font.draw("astronauts home: #{@lander.safe_astronaut_count}", 640, 10, 3, 1.0, 1.0,
               0xffffff00)
    @font.draw("fuel: #{@lander.fuel.to_int}", 840, 10, 3, 1.0, 1.0,
               @lander.fuel > 20 ? 0xffffff00 : 0xffff0000)
    @font.draw("health: #{@lander.health.to_int}", 840, 60, 3, 1.0, 1.0, 0xffffff00)
    @font.draw("velocity: %0.2f" %(@lander.vel * 10), 100, 10, 3,
               1.0, 1.0, 0xffffff00)
    @font.draw("crash velocity: %0.2f" % (@lander.crash_velocity.round_to(3) * 10), 100, 30, 3,
               1.0, 1.0, 0xffffff00)
    @font.draw("wind y: #{@wind[1].round_to(3) * 10}", 100, 50, 3, 1.0, 1.0, 0xffffff00)
    @font.draw("wind x: #{@wind[0].round_to(3) * 10}", 100, 70, 3, 1.0, 1.0, 0xffffff00)
    @font.draw("Precision Controls: #{@lander.da.round_to(5) * 10}", 100, 90, 3, 1.0, 1.0, 0xff00ff00) if @lander.has_precision_controls
    @font.draw("Shield: #{@lander.shield_remaining.to_int}", 100, 110, 3, 1.0, 1.0, 0xff00ff00) if @lander.has_shield
  end

  def name
    :playgame
  end

  def level_complete?
    @level_complete
  end

  def level_fail?
    @level_fail
  end
end
