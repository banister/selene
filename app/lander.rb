class Lander
    include BoundingBox
    include Tasks
    
    attr_accessor :landed
    attr_reader :fuel, :width, :height, :vel, :died, :da, :x, :y, :vx, :vy
    attr_reader :has_shield, :crash_velocity, :health, :has_precision_controls
    
    CRASH_VELOCITY = 0.6
    FUEL = 2000000
    HEALTH = 100000
    SHIELD_RADIUS = 180
    SHIELD_TIMEOUT = 60
    MAX_CAREEN_ANGLE = 60
    NORMAL_JET_COLOR = [255, 255, 200, 200]
    QUANTUM_JET_COLOR = [255, 120, 120, 255]
    DELTA_THETA = 2

    def initialize(window, playgame, x, y)
        @xpos = x
        @ypos = y
        @x, @y = x, y
        @vx = @vy = 0
        @da = 0.1
        @window = window
        @health = HEALTH
        @health_meter = HealthMeter.new
        @playgame = playgame
        @crash_velocity = CRASH_VELOCITY - @playgame.level / 60.0
        @fuel = FUEL - @playgame.level * 2

        # let's put reasonable limits on fuel and crash velocity
        @fuel = 40 if @fuel < 40
        @crash_velocity = 0.17 if @crash_velocity < 0.17

        self.landed = false
        @died = false
        
        @jet_color = NORMAL_JET_COLOR

        init_sounds

        @image = Gosu::Image.new(@window, "#{MEDIA}/lander.png")

        set_bounding_box(@image.width, @image.height)

        # TEMPORARY SOLUTION !!
        @shield_image = TexPlay::create_blank_image(@window, SHIELD_RADIUS * 2, SHIELD_RADIUS * 2)
        @shield_image.circle SHIELD_RADIUS, SHIELD_RADIUS, SHIELD_RADIUS, :color => [0.1, 0.1, 1, 0.1], :fill => true
        # END TEMPORARY SOLUTION

        @height = @image.height
        @width = @image.width
        @theta = 0
    end

    def init_sounds
        @scream_sound = Gosu::Sample.new(@window, "#{MEDIA}/scream.ogg")
        @jet_sound = Gosu::Sample.new(@window, "#{MEDIA}/jet3.ogg")
        @collide_sound = Gosu::Sample.new(@window, "#{MEDIA}/collide.ogg")
        @fuel_sound = Gosu::Sample.new(@window, "#{MEDIA}/lowfuel.ogg")
        @shield_deflect_sound = Gosu::Sample.new(@window, "#{MEDIA}/shield.ogg")
    end

    def handle_controls
        move_left if @window.button_down? Gosu::KbLeft
        move_right if @window.button_down? Gosu::KbRight
        move_up if @window.button_down? Gosu::KbUp
        move_down if @window.button_down? Gosu::KbDown
    end

    def screen_at
        case 
        when @x < -30
            :left
        when @x > 1070
            :right
        when @y > 788
            :bottom
        when @y < -30
            :top
        else
            :current
        end
    end

    def update
        handle_controls
        check_tasks

        if touch_down?
            if !self.landed
                @vx = 0
                @vy = 0
            end
            @vy = 0 if @vy >= 0
            @vx = 0
            @y += @vy
            self.landed = true
        else
            @x += @vx
            @y += @vy 
            @vy += PlayGame::Gravity
            
            if !@has_precision_controls
                @vx += @playgame.wind[0]
                @vy += @playgame.wind[1]
            end
            self.landed = false
        end
        
        if terrain_touch_down?
            if vel > @crash_velocity then
                @died = true
            end
        elsif crashed?
            @died = true
        elsif @health <= 0 then
            @died = true
            #         elsif (@x > 1070 || @x < -30 || @y > 788) && @fuel <= 0 then
            #             @died = true
            #             @scream_sound.play(1.0)
        end

        @theta -= DELTA_THETA / 2 if @theta > 0
        @theta += DELTA_THETA / 2 if @theta < 0
    end

    # magnitude of velocity vector
    def vel
        Math::hypot(@vx, @vy)
    end

    def crashed?
        @playgame.map.solid?(@x, @y) || @playgame.map.solid?(@x, @y - @height / 2) ||
            @playgame.map.solid?(@x + @width / 4, @y) || @playgame.map.solid?(@x - @width / 4, @y) && self.vel > @crash_velocity
    end

    def left_foot
        [@x + @width / 2, @y + @height / 2]                
    end

    def right_foot
        [@x - @width / 2, @y + @height / 2]        
    end
    
    def touch_down?
        terrain_touch_down? || platform_touch_down?
    end

    def terrain_touch_down?
        @playgame.map.solid?(*left_foot) &&
            @playgame.map.solid?(*right_foot)
    end

    def platform_touch_down?
        @playgame.platform_manager.each { |platform|
            if platform.solid?(*left_foot) &&
                    platform.solid?(*right_foot)
                got_shield(0.1)
                return true
            end
        }
        false
    end

    def impulse(dvx, dvy)
        @vx += dvx
        @vy += dvy
    end

    def health=(h)
        @health = h
        @health_meter.update_health_status(h.to_f / HEALTH)
    end

    def object_hit(meteor, damage, impulse_factor = 1)
        self.health -= damage

        @collide_sound.play(1.0)
        chunk_size = 20

        # ignore the case for Wreckage
        if !meteor.is_a?(Wreckage)

            # if the meteor is going in the direction that ship is going and it's in FRONT of ship, then significantly reduce velocity (give velocity to meteor)
            if meteor.vx.sgn == @vx.sgn && (meteor.x - @x).sgn == @vx.sgn
                @vx /= 3

            # otherwise just add velocity
            else
                @vx += meteor.vx * impulse_factor
            end

            # same for y component
            if (meteor.vy.sgn == @vy.sgn) && (meteor.y - @y).sgn == @vy.sgn
                @vy /= 3
            else
                @vy += meteor.vy * impulse_factor
            end
        end
        
        x = rand(@image.width - chunk_size)
        y = rand(@image.height - chunk_size)

        chunk = [x, y, x + chunk_size, y + chunk_size]

        # damage the craft
        @image.splice @image, x - 4 + rand(7), y - 4 + rand(7),
        :crop => chunk,
        :color_control => proc { |c, c1|
            c1[0] /= 1.7
            c1[1] /= 2.1 
            c1[2] /= 2.1

            c1
        }

        debris = TexPlay::create_blank_image(@window, chunk_size, chunk_size)
        debris.splice @image, 0, 0, :crop => chunk

        @playgame.objects <<  Particle.new(@window, @x, @y)#  << Particle.new(@window, @x, @y,
        #                                                                             :image => debris,
        #                                                                             :direction => :random,
        #                                                                             :rotate => true,
        #                                                                             :lifespan => 1)

        if(!meteor.is_a?(Wreckage))
            start_dist = Math::hypot(@image.width / 2, @image.height / 2) + 2
            angle = 2 * Math::PI * rand
            dx = Math::cos(angle)
            dy = Math::sin(angle)
            
            @playgame.objects << Wreckage.new(@window, @playgame,
                                              @x + dx * start_dist,
                                              @y + dy * start_dist, debris)
        end
    end

    def got_shield(timeout = SHIELD_TIMEOUT)
        @has_shield = true
        
        after(timeout, :name => :shield_timeout) { @has_shield = false }
    end

    def shield_remaining
        return 0 if !task_exists?(:shield_timeout)

        task_time_remaining(:shield_timeout)
    end

    def shield_intersect?(m)
        @has_shield && Math::hypot(m.x - @x, m.y - @y) < SHIELD_RADIUS
    end

    def shield_hit(m)
        @shield_image.draw_rot(@xpos, @y, 1, 0) if @has_shield

        @shield_deflect_sound.play(0.5)
        @playgame.objects <<  Particle.new(@window, m.x, m.y,
                                           :color => [255, 100, 100, 255])
    end

    def refuel(v=100)
        @fuel += v
    end

    def got_quantum_engine
        extend QuantumEngine::PrecisionControl

        refuel(1000)

        @jet_color = QUANTUM_JET_COLOR
        @has_precision_controls = true
    end

    def accel(dvx, dvy)
        return if @fuel <= 0 

        deviance = (1 - (@health / HEALTH.to_f)) / 4.0

        @vx += dvx + deviance / 3 * rand 
        @vy += dvy + deviance / 3 * rand 
        
        @fuel_sound.play(0.05) if @fuel <= 20
        @fuel -= 1 * (@da * 10)

        if dvx.sgn != 0 && !landed
            @jet_sound.play(0.04)
            sgn = dvx.sgn
            direc = sgn > 0 ? :left : :right
            @playgame.objects << Particle.new(@window, @x + 25 * -sgn , @y - 16,
                                              :direction => direc,
                                              :scale => 0.1,
                                              :color => @jet_color
                                              )
            if @theta > -MAX_CAREEN_ANGLE && @theta < MAX_CAREEN_ANGLE
                @theta += DELTA_THETA * sgn
            end
            
        elsif dvy.sgn != 0
            @jet_sound.play(0.04)
            sgn = dvy.sgn
            direc = sgn > 0 ? :up : :down
            @playgame.objects << Particle.new(@window, @x , @y + 20 * -sgn,
                                              :direction => direc,
                                              :scale => 0.1,
                                              :color => @jet_color
                                              )
        end
    end

    def move_left
        accel(-@da, 0)
    end
    
    def move_right
        accel(@da, 0)
    end

    def move_up
        accel(0, -@da)
    end

    def move_down
        accel(0, @da)
    end
    
    def draw
        # shake the craft when damaged
        shake = (1 - @health.to_f / HEALTH) * 20
        
        @image.draw_rot @xpos, @y, 1, @theta + rand(shake) - shake / 2
        #@image.sdraw_rot @x, @y, 1, @theta + rand(shake) - shake / 2
        @health_meter.draw_rot @xpos, @y - 50, 1, 0
    end
end
