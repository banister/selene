class PlayGame
    include Tasks
    
    attr_accessor :objects
    attr_reader :map, :lander, :level, :wind, :difficulty
    
    Gravity = 0.002
    LandGravity = 0.1
    Wind_Velocity = 0.005
    FREEZE_MOVEMENT_TIMEOUT = 20

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
        @lander = Lander.new(@window, self, 600, 100)

        @difficulty = Difficulty.new(self)
        @meteor_manager = MeteorManager.new(@window, self)
        @powerup_manager = PowerUpManager.new(@window, self)
        @platform_manager = PlatformManager.new(@window, self)
        @astronaut_manager = AstronautManager.new(@window, self)

        @objects << @astronaut_manager

        place_platforms
        place_astronauts
    end

    def place_platforms
        3.times { 
            @platform_manager.add_platform :x => rand(800) + 100, :y => 300, :screen => rand(5)
        }
#        @platform_manager.add_platform :x => rand(800) + 100, :y => 300, :screen => 2
        @platform_manager.screen_is(0)
    end

    def place_astronauts
        15.times { 
            @astronaut_manager.add_astronaut :x => rand(800) + 100, :y => 300, :screen => rand(5)
        }
 #       @astronaut_manager.add_astronaut :x => rand(800) + 100, :y => 300, :screen => 2
        @astronaut_manager.screen_is(0)
    end
    

    def freeze_movement
        @freeze_movement = true

        # unfreeze movement in FREEZE_MOVEMENT_TIMEOUT seconds
        new_task(:wait => FREEZE_MOVEMENT_TIMEOUT, :name => :freeze_timeout) {
            @freeze_movement = false
        }
    end

    def is_movement_frozen?
        @freeze_movement
    end

    def update
        check_tasks
 
        @meteor_manager.update
        @powerup_manager.update
        @platform_manager.update
        @lander.update

        @objects.reject! { |m| m.update == false }
        
        case @lander.screen_at
        when :left
            @map.change_screen_to(:left)
            @lander.x = 1000
            @meteor_manager.move_meteors_by(1022, 0)
            @astronaut_manager.screen_is(@map.current_screen)
            @platform_manager.screen_is(@map.current_screen)
        when :right
            @map.change_screen_to(:right)
            @lander.x = 10
            @meteor_manager.move_meteors_by(-1022, 0)
            @astronaut_manager.screen_is(@map.current_screen)
            @platform_manager.screen_is(@map.current_screen)
        when :top
            @map.change_screen_to(:top)
            @lander.y = 700
            @meteor_manager.reset.add_and_randomize(10)
            @meteor_manager.frequency *= 3
            @powerup_manager.start
            @astronaut_manager.screen_is(nil)
            @platform_manager.screen_is(nil)
        when :bottom
            @map.change_screen_to(:bottom)
            @lander.y = 10
            @meteor_manager.move_meteors_by(0, -780)
            @meteor_manager.frequency /= 3
            @powerup_manager.reset.stop
            @astronaut_manager.screen_is(@map.current_screen)
            @platform_manager.screen_is(@map.current_screen)
        end

        if @lander.landed then
 ###           @triumph_sound.play(1.0)
#            @level_complete = true
        elsif @lander.died then
            @crash_sound.play(1.0)
            @level_fail = true
        end
    end
    
    def draw
        @map.draw
        @lander.draw
        @objects.each { |m| m.draw }

        @font.draw("screen: #{@map.current_screen}", 340, 10, 3, 1.0, 1.0,
                   @lander.fuel > 20 ? 0xffffff00 : 0xffff0000)

        @font.draw("fuel: #{@lander.fuel}", 840, 10, 3, 1.0, 1.0,
                   @lander.fuel > 20 ? 0xffffff00 : 0xffff0000)
        @font.draw("health: #{@lander.health}", 840, 60, 3, 1.0, 1.0, 0xffffff00)
        @font.draw("velocity: #{@lander.vel.round_to(3) * 10}", 100, 10, 3,
                   1.0, 1.0, 0xffffff00)
        @font.draw("crash velocity: #{@lander.crash_velocity.round_to(3) * 10}", 100, 30, 3,
                   1.0, 1.0, 0xffffff00)
        @font.draw("wind y: #{@wind[1].round_to(3) * 10}", 100, 50, 3, 1.0, 1.0, 0xffffff00)
        @font.draw("wind x: #{@wind[0].round_to(3) * 10}", 100, 70, 3, 1.0, 1.0, 0xffffff00)
        
        @font.draw("Precision Controls: #{@lander.da.round_to(5) * 10}", 100, 90, 3, 1.0, 1.0, 0xff00ff00) if @lander.has_precision_controls
        @font.draw("Shield: #{@lander.shield_remaining.round_to(3)}", 100, 110, 3, 1.0, 1.0, 0xff00ff00) if @lander.has_shield
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
