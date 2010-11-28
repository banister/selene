class Lander
  include BoundingBox
  include Tasks
  
  attr_accessor :landed, :active
  attr_reader :fuel, :width, :height, :vel, :da, :x, :y, :vx, :vy
  attr_reader :astronaut_count, :safe_astronaut_count, :cloaked
  attr_reader :has_shield, :crash_velocity, :health, :has_precision_controls
  
  CRASH_VELOCITY = 0.6
  FUEL = 1000
  HEALTH = 1000
  SHIELD_RADIUS = 180
  SHIELD_TIMEOUT = 60
  MAX_CAREEN_ANGLE = 60
  NORMAL_JET_COLOR = [255, 255, 200, 200]
  QUANTUM_JET_COLOR = [255, 120, 120, 255]
  DELTA_THETA = 2
  MINIMUM_CHUNK_SIZE = 2
  MAXIMUM_CHUNK_SIZE = 20
  PLATFORM_HEAL_RATE = 2

  def initialize(window, playgame, x, y)
    @xpos = x
    @ypos = y
    @x, @y = x, y
    @vx = @vy = 0
    @da = 0.1
    @window = window
    @health = HEALTH
    @safe_astronaut_count = @astronaut_count = 0
    @health_meter = HealthMeter.new
    @playgame = playgame
    @cloaked = false
    @crash_velocity = 1.5 #CRASH_VELOCITY - @playgame.level / 60.0
    @fuel = FUEL - @playgame.level * 2

    # let's put reasonable limits on fuel and crash velocity
    @fuel = 40 if @fuel < 40
    @crash_velocity = 0.17 if @crash_velocity < 0.17

    self.landed = false
    @active = true
    
    @jet_color = NORMAL_JET_COLOR

    init_sounds

    @image = Gosu::Image.new(@window, "#{MEDIA}/lander.png").cache
    @undamaged_image = @image.dup
    
    set_bounding_box(@image.width, @image.height)

    # TEMPORARY SOLUTION !!
    @shield_image = TexPlay.create_blank_image(@window, SHIELD_RADIUS * 2, SHIELD_RADIUS * 2)
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

    if @window.button_down? Gosu::KbSpace
      laser_fire
    end
  end

  def laser_fire
    ty = @playgame.lander.y + @playgame.lander.height / 2 + 4
    before(2, :name => :laser_timeout, :preserve => true) do
      @playgame.objects << Bullet.new(@playgame, x, ty, -3, 0)
    end
  end

  def landed?
    self.landed
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
      self.y += @vy
      self.landed = true
    else
      self.x += @vx
      Win.screen_x += @vx
      
      self.y += @vy
      @vy += PlayGame::Gravity
      
      if !@has_precision_controls
        @vx += @playgame.wind[0]
        @vy += @playgame.wind[1]
      end
      self.landed = false
    end
    
    if terrain_touch_down?
      if vel > @crash_velocity then
        @active = false
      end
    elsif crashed?
      @active = false
    elsif @health <= 0 then
      @active = false
      #         elsif (@x > 1070 || @x < -30 || @y > 788) && @fuel <= 0 then
      #             @died = true
      #             @scream_sound.play(1.0)
    end

    @theta -= DELTA_THETA / 2 if @theta > 0
    @theta += DELTA_THETA / 2 if @theta < 0

    # quantum engine causes health/fuel to recharge over time
    if is_a?(QuantumEngine::PrecisionControl)
      self.heal_over_time(0.5) if @health < HEALTH
      self.refuel_over_time(0.08) if @fuel < FUEL
    end
  end

  # magnitude of velocity vector
  def vel
    Math::hypot(@vx, @vy)
  end

  def crashed?
    @playgame.map.solid?(@x, @y) || @playgame.map.solid?(@x, @y - @height / 2) ||
      @playgame.map.solid?(@x + @width / 4, @y) || @playgame.map.solid?(@x - @width / 4, @y) && self.vel > @crash_velocity
  end

  def got_astronaut
    @astronaut_count += 1
  end

  def unload_astronaut
    if @astronaut_count >= 1
      @astronaut_count -= 1
      @safe_astronaut_count += 1
    end
  end

  def unload_astronauts_over_time
    after(2, :name => :astronaut_unload_timeout, :preserve => true) {
      unload_astronaut
    }
  end    

  def middle_foot
    [@x, @y + @height / 2]
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
    (@playgame.map.solid?(*left_foot) && @playgame.map.solid?(*middle_foot)) ||
    (@playgame.map.solid?(*right_foot) && @playgame.map.solid?(*middle_foot))
  end

  def platform_touch_down?
    @playgame.platform_manager.each { |platform|
      if (platform.solid?(*left_foot) &&
          platform.solid?(*middle_foot)) ||
          (platform.solid?(*right_foot) &&
          platform.solid?(*middle_foot))
        platform.landing_action(self)
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
    old_health = @health
    @health = h
    @health = 3 * HEALTH if @health > 3 * HEALTH
    @health_meter.update_health_status(h.to_f / HEALTH)
    health_delta = @health - old_health
    
    # restore to undamaged ship if health is now full
    if old_health < HEALTH && @health >= HEALTH
      @image.splice @undamaged_image, 0, 0

    # otherwise incrementally repair the ship
    elsif health_delta > 0 && @health < HEALTH
      chunk_size = MAXIMUM_CHUNK_SIZE * (health_delta / 50.0)
      chunk_size = MINIMUM_CHUNK_SIZE if chunk_size < MINIMUM_CHUNK_SIZE
      chunk_size = MAXIMUM_CHUNK_SIZE if chunk_size > MAXIMUM_CHUNK_SIZE

      # special case for healing platform
      chunk_size = 4 if health_delta == PLATFORM_HEAL_RATE

      # puts "chunk size #{chunk_size}"
      # puts "h #{h}"
      # puts "MAXIMUM_CHUNK_SIZE * (h / 50.0) is #{MAXIMUM_CHUNK_SIZE * (h / 50.0)}"
      
      
      x = rand(@image.width - chunk_size)
      y = rand(@image.height - chunk_size)
      chunk = [x, y, x + chunk_size, y + chunk_size]

      # repair ship
      @image.splice @undamaged_image, x, y, :crop => chunk
    end
  end

  def heal(h=300)
    self.health += h
  end

  def heal_over_time(rate=PLATFORM_HEAL_RATE)
    before(0.01, :name => :health_timeout, :preserve => true) {
      self.health += rate
    }
  end

  def object_hit(meteor, damage, impulse_factor = 1)
    self.health -= damage

    @collide_sound.play(1.0)

    chunk_size = MAXIMUM_CHUNK_SIZE * (damage / 50.0)
    chunk_size = MINIMUM_CHUNK_SIZE if chunk_size < 4
    chunk_size = MAXIMUM_CHUNK_SIZE if chunk_size > 20

    # ignore the case for Wreckage
    if !meteor.is_a?(Wreckage)

      # if the meteor is going in the direction that ship is going and it's in FRONT of ship
      # then significantly reduce velocity (give velocity to meteor)
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
    
    if @health <= HEALTH
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
    end

    if @debris.nil?
      @debris = TexPlay.create_blank_image(@window, chunk_size, chunk_size)
      @debris.splice @image, 0, 0, :crop => chunk
    end

    @playgame.objects <<  Particle.new(@window, @x, @y)

    if(!meteor.is_a?(Wreckage))
      start_dist = Math::hypot(@image.width / 2, @image.height / 2) + 2
      angle = 2 * Math::PI * rand
      dx = Math::cos(angle)
      dy = Math::sin(angle)
      
      @playgame.objects << Wreckage.new(@window, @playgame,
                                        @x + dx * start_dist,
                                        @y + dy * start_dist, @debris)
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

  def refuel(v=300)
    @fuel += v
    @fuel = 3 * FUEL if @fuel > 3 * FUEL
  end

  def refuel_over_time(rate=2)
    before(0.01, :name => :refuel_timeout, :preserve => true) {
      refuel(rate)
    }
  end

  def got_quantum_engine
    extend QuantumEngine::PrecisionControl if !self.is_a? QuantumEngine::PrecisionControl

    @jet_color = QUANTUM_JET_COLOR
    @has_precision_controls = true
  end

  def got_cloaking
    @cloaked = true
    after(20, :name => :cloaking_timeout) {
      @cloaked = false
    }
  end

  def accel(dvx, dvy)
    return if @fuel <= 0 
    deviance = 0
    deviance = (1 - (@health / HEALTH.to_f)) / 4.0 if @health < HEALTH

    @vx += dvx + deviance / 3 * rand 
    @vy += dvy + deviance / 3 * rand 
    
    @fuel_sound.play(0.05) if @fuel <= 100
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
    shake = 0
    shake = (1 - @health.to_f / HEALTH) * 20 if @health < HEALTH

    @image.draw_rot @xpos, @y, 1, @theta + rand(shake) - shake / 2, 0.5, 0.5, 1, 1,
    @cloaked ? 0x80ffffff : 0xffffffff
    @health_meter.draw_rot @xpos, @y - 50, 1, 0
  end
end
