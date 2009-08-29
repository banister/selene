class PlayGame
    include Tasks
    
    attr_reader :map, :lander, :level, :objects
    
    
    CUR_DIREC = File.dirname(__FILE__)   

    Gravity = 0.002

    Wind_Velocity = 0.005

    Wind = [0, 0]

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

        @meteor_frequency = 0.08 + @level / 1000.0

        @refuel_frequency = 0.001 + @level / 50000.0
        
        Wind[0] = rand * Wind_Velocity - Wind_Velocity / 2
        Wind[1] = rand * Wind_Velocity - Wind_Velocity / 2

        puts "wind before factor #{Wind.inspect}"

        if @level > 20 then
            factor = 1 + 0.2 * (@level - 20)

            factor = 8 if factor > 8
            puts "factor #{factor}"
            
            Wind[0] *= factor
            Wind[1] *= factor
        end

        puts "wind after factor #{Wind.inspect}"


        @objects = []
        @lander = Lander.new(@window, self, 600, 100)
        @difficulty = IncrementalDifficulty.new(self)
    end

    def freeze_movement
        @freeze_movement = true

        # unfreeze movement in FREEZE_MOVEMENT_TIMEOUT seconds
        new_task(:wait => FREEZE_MOVEMENT_TIMEOUT, :name => :freeze_timeout) { @freeze_movement = false}
    end

    def is_movement_frozen?
        @freeze_movement
    end

    def update
        check_tasks
 
        if rand < @difficulty.meteor_frequency && !is_movement_frozen? then
            @objects << SmallMeteor.new(@window, self, 1024 * rand, -20)
        end

        if rand < @refuel_frequency then
            @objects << RocketJuice.new(@window, self, 1024 * rand, rand(400))
        end

        if rand < @refuel_frequency then
            @objects << QuantumEngine.new(@window, self, 1024 * rand, rand(400))
        end

        if rand < @refuel_frequency then
            @objects << Shield.new(@window, self, 1024 * rand, rand(400))
        end

        if rand < @refuel_frequency then
            @objects << Freeze.new(@window, self, 1024 * rand, rand(400))
        end

        @lander.update
        @objects.reject! { |m| m.update == false }

        if @lander.landed then
            @triumph_sound.play(1.0)
            @level_complete = true
        elsif @lander.crashed then
            @crash_sound.play(1.0)
            @level_fail = true
        end
    end
    
    def draw
        @map.draw
        @lander.draw
        @objects.each { |m| m.draw }

        @font.draw("fuel: #{@lander.fuel}", 840, 10, 3, 1.0, 1.0,
                   @lander.fuel > 20 ? 0xffffff00 : 0xffff0000)
        @font.draw("health: #{@lander.health}", 840, 60, 3, 1.0, 1.0, 0xffffff00)
        @font.draw("velocity: #{@lander.vel.round_to(3) * 10}", 100, 10, 3,
                   1.0, 1.0, 0xffffff00)
        @font.draw("crash velocity: #{@lander.crash_velocity.round_to(3) * 10}", 100, 30, 3,
                   1.0, 1.0, 0xffffff00)
        @font.draw("wind y: #{Wind[1].round_to(3) * 10}", 100, 50, 3, 1.0, 1.0, 0xffffff00)
        @font.draw("wind x: #{Wind[0].round_to(3) * 10}", 100, 70, 3, 1.0, 1.0, 0xffffff00)
        
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
