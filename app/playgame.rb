class PlayGame
    include Tasks
    
    attr_accessor :objects
    attr_reader :map, :lander, :platform_manager, :meteor_manager, :turret_manager
    attr_reader :level, :wind, :difficulty, :powerup_manager
    
    
    Gravity = 0.002
    LandGravity = 0.1
    Wind_Velocity = 0.005
    FREEZE_MOVEMENT_TIMEOUT = 20
    AstronautCount = 5

    def initialize(window, level)
        @window = window
        @level_complete = false
        @level_fail = false
        @level = level
        @freeze_movement = false
        @map = Map.new(@window)
        @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)

        @triumph_sound = Gosu::Sample.new(@window, "#{MEDIA}/triumph.ogg")
        @crash_sound = Gosu::Sample.new(@window, "#{MEDIA}/smash.ogg")

        @wind = []

        @wind[0] = rand * Wind_Velocity - Wind_Velocity / 2
        @wind[1] = rand * Wind_Velocity - Wind_Velocity / 2

        if @level > 20 then
            factor = 1 + 0.2 * (@level - 20)

            factor = 8 if factor > 8
            
            @wind[0] *= factor
            @wind[1] *= factor
        end

        @objects = []
        @lander = Lander.new(@window, self, 90 + Map::WIDTH / 2, Map::HEIGHT / 2 - 184)
        Win.screen_x = 0

        @difficulty = Difficulty.new(self)
        @meteor_manager = MeteorManager.new(@window, self)
        @turret_manager = TurretManager.new(@window, self)

      @powerup_manager = PowerUpManager.new(@window, self)
        @platform_manager = PlatformManager.new(@window, self)
        @astronaut_manager = AstronautManager.new(@window, self)

        @objects << @astronaut_manager
        @objects << @platform_manager
        @objects << @meteor_manager
        @objects << @turret_manager
        @objects << @powerup_manager

        place_platforms
        place_astronauts
        place_turrets
    end

    def place_platforms
        7.times { 
            @platform_manager.add_platform :x => rand(@map.total_map_width), :y => 100
        }
        # Red platform
        @platform_manager.add_platform :type => RedPlatform,
        :x => rand(@map.total_map_width), :y => 100

        # Green platform
        @platform_manager.add_platform :type => GreenPlatform,
        :x => rand(@map.total_map_width), :y => 100

        # Blue platform
        @platform_manager.add_platform :type => BluePlatform,
        :x => rand(@map.total_map_width), :y => 100
    end

    def place_astronauts
        AstronautCount.times { 
            @astronaut_manager.add_astronaut :x => rand(@map.total_map_width), :y => 100
        }
    end

    def place_turrets
        8.times { 
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
        

        if @lander.safe_astronaut_count == AstronautCount then
            @triumph_sound.play(1.0)
            @level_complete = true
        elsif !@lander.active then
            @crash_sound.play(1.0)
            @level_fail = true
        end

#        Win.screen_x =  @lander.x
#        Win.screen_y +=  @lander.vy
    end
    
    def draw
        @map.draw
        @lander.draw
        @objects.each { |m| m.draw }

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
