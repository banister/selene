

class Lander 
    include BoundingBox
    include Tasks
    
    attr_reader :fuel, :width, :height, :vel, :crashed, :landed, :da, :x, :y
    attr_reader :has_shield, :crash_velocity, :health, :has_precision_controls
    
    CUR_DIREC = File.dirname(__FILE__)

    CRASH_VELOCITY = 0.6
    FUEL = 200
    HEALTH = 100
    SHIELD_RADIUS = 180
    SHIELD_TIMEOUT = 60
    MAX_CAREEN_ANGLE = 60
    NORMAL_JET_COLOR = [255, 255, 200, 200]
    QUANTUM_JET_COLOR = [255, 120, 120, 255]
    DELTA_THETA = 2

    def initialize(window, playgame, x, y)
        @x, @y = x, y
        @vx = @vy = 0
        @da = 0.1
        @window = window
        @health = HEALTH
        @playgame = playgame
        @crash_velocity = CRASH_VELOCITY - @playgame.level / 60.0
        @fuel = FUEL - @playgame.level * 2

        # let's put reasonable limits on fuel and crash velocity
        @fuel = 40 if @fuel < 40
        @crash_velocity = 0.17 if @crash_velocity < 0.17

        @landed = false
        @crashed = false

        @scream_sound = Gosu::Sample.new(@window, "#{CUR_DIREC}/media/scream.ogg")
        @jet_sound = Gosu::Sample.new(@window, "#{CUR_DIREC}/media/jet3.ogg")
        @collide_sound = Gosu::Sample.new(@window, "#{CUR_DIREC}/media/collide.ogg")
        @fuel_sound = Gosu::Sample.new(@window, "#{CUR_DIREC}/media/lowfuel.ogg")
        @shield_deflect_sound = Gosu::Sample.new(@window, "#{CUR_DIREC}/media/shield.ogg")

        @jet_color = NORMAL_JET_COLOR

        @image = Gosu::Image.new(@window, "#{CUR_DIREC}/media/lander.png")

        set_bounding_box(@image.width, @image.height)

        # TEMPORARY SOLUTION !!
        @shield_image = TexPlay::create_blank_image(@window, SHIELD_RADIUS * 2, SHIELD_RADIUS * 2)
        @shield_image.circle SHIELD_RADIUS, SHIELD_RADIUS, SHIELD_RADIUS, :color => [0.1, 0.1, 1, 0.1], :fill => true
        # END TEMPORARY SOLUTION

        @height = @image.height
        @width = @image.width
        @theta = 0
    end

    def handle_controls
        move_left if @window.button_down? Gosu::KbLeft
        move_right if @window.button_down? Gosu::KbRight
        move_up if @window.button_down? Gosu::KbUp
        move_down if @window.button_down? Gosu::KbDown
    end

    def update
        handle_controls
        check_tasks
        
        @x += @vx
        @y += @vy

        @vx += PlayGame::Wind[0]
        @vy += PlayGame::Gravity + PlayGame::Wind[1]

        if @playgame.map.solid?(@x - @width / 2, @y + @height / 2) ||
                @playgame.map.solid?(@x + @width / 2, @y + @height / 2) then
            if vel > @crash_velocity then
                @crashed = true
            else
                @landed = true
            end
        elsif @health <= 0 then
            @crashed = true
        elsif (@x > 1070 || @x < -30 || @y > 788) && @fuel <= 0 then
            @crashed = true
            @scream_sound.play(1.0)
        end

        @theta -= DELTA_THETA / 2 if @theta > 0
        @theta += DELTA_THETA / 2 if @theta < 0
    end

    # magnitude of velocity vector
    def vel
        Math::hypot(@vx, @vy)
    end

    def meteor_hit(meteor, damage)
        @health -= damage

        @collide_sound.play(1.0)
        chunk_size = 20

        @vx += meteor.vx
        @vy += meteor.vy
        
        x = rand(@image.width - chunk_size)
        y = rand(@image.height - chunk_size)

        chunk = [x, y, x + chunk_size, chunk_size]

        # damage the craft
        @image.splice @image, x - 4 + rand(7), y - 4 + rand(7),
        :crop => chunk,
        :color_control => proc { |c, c1|
            c1[0] /= 1.7
            c1[1] /= 2.1 
            c1[2] /= 2.1

            c1
        }

        @playgame.objects <<  Particle.new(@window, @x, @y)
    end

    def got_shield
        @has_shield = true

        new_task(:wait => SHIELD_TIMEOUT, :name => :shield_timeout) { @has_shield = false }
    end

    def shield_remaining
        return 0 if !task_exists?(:shield_timeout)

        task_time_remaining(:shield_timeout)
    end

    def shield_intersect?(m)
        if @has_shield && Math::hypot(m.x - @x, m.y - @y) < SHIELD_RADIUS
            true
        else
            false
        end
    end

    def shield_hit(m)
        @shield_image.draw_rot(@x, @y, 1, 0) if @has_shield

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
        
        @jet_sound.play(0.04)

        deviance = (HEALTH - @health) / HEALTH.to_f

        @vx += dvx + deviance / 3 * rand
        @vy += dvy + deviance / 3 * rand
        
        @fuel_sound.play(0.05) if @fuel <= 20
        @fuel -= 1

        if dvx.sgn == 1
            @playgame.objects << Particle.new(@window, @x - 25 , @y - 16,
                                              :direction => :left,
                                              :scale => 0.1,
                                              :color => @jet_color
                                              )
            @theta += DELTA_THETA if @theta < MAX_CAREEN_ANGLE

        elsif dvx.sgn == -1
            @playgame.objects << Particle.new(@window, @x + 25 , @y - 16,
                                              :direction => :right,
                                              :scale => 0.1,
                                              :color => @jet_color
                                              )
            @theta -= DELTA_THETA if @theta > -MAX_CAREEN_ANGLE

        elsif dvy.sgn == -1
            @playgame.objects << Particle.new(@window, @x , @y + 20,
                                              :direction => :down,
                                              :scale => 0.1,
                                              :color => @jet_color
                                              )
        elsif dvy.sgn == 1
            @playgame.objects << Particle.new(@window, @x , @y - 20,
                                              :direction => :up,
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
        @image.draw_rot @x, @y, 1, @theta

#        @shield_image.draw_rot(@x, @y, 1, 0) if @has_shield
    end
end
