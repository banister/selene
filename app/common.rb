MEDIA = File.dirname(__FILE__) + '/media'

Point = Struct.new(:x, :y)

class Gosu::Image
    
    def sdraw(*args)
        x = args.shift - Win.screen_x
        y = args.shift - Win.screen_y
        
        return if x > Map::WIDTH || x < -self.width || y > Map::HEIGHT || y < -self.height
        
        draw(x, y, *args)
    end
    
    def sdraw_rot(*args)
        x = args.shift - Win.screen_x
        y = args.shift - Win.screen_y
        halfwidth = self.width / 2
        halfheight = self.height / 2
        
        return if x > Map::WIDTH + halfwidth ||
            x < -halfwidth || y > Map::HEIGHT + halfheight || y < -halfheight
        
        draw_rot(x, y, *args)
    end

    def solid?(x, y)
        return false if x < 0 || x > (self.width - 1) || y < 0 || y > (self.height - 1)
        
        # a pixel is solid if the alpha channel is not 0
        self.get_pixel(x, y) && self.get_pixel(x, y)[3] != 0
    end    
end

## monkey patches to Vector
class Vector
    def normalize
        self * (1.0 / self.r)
    end
end

## monkey patches to core classes 
class Numeric
    def round_to(n=0)
        return self.to_i if n == 0
        
        ((self * (10 ** n)).to_i) / (10 ** n).to_f
    end

    def sgn
        self <=> 0
    end

    def to_radians
        (self / 180.0) * Math::PI
    end

    def to_degrees
        (self / Math::PI) * 180.0
    end
end

class Array
    def random
        self[rand(size)]
    end
end
## end monkey patches

module BoundingBox
    attr_accessor :x, :y
    attr_reader :x_offset
    attr_reader :y_offset

    # reduce bounding box size for more refined collisions
    Shrink = 0.7

    def set_bounding_box(xsize, ysize)

        @x_offset = (xsize * Shrink / 2).to_i
        @y_offset = (ysize * Shrink / 2).to_i
    end
    
    def intersect?(other)
        oy = other.y.to_i
        ox = other.x.to_i
        oy_offset = other.y_offset.to_i
        ox_offset = other.x_offset.to_i
        
         @y - @y_offset < oy + oy_offset && @y + @y_offset > oy - oy_offset &&
                @x - @x_offset < ox + ox_offset && @x + @x_offset > ox - ox_offset
    end

    def point_intersect?(other)
        other.x > @x - @x_offset && other.x < @x + @x_offset &&
            other.y > @y - @y_offset && other.y < @y + @y_offset
    end
end

# inspired by phelps (Deathly Dimensions)
# tasks NEED a name so that new (updated) tasks can overwrite their older versions that have
# not yet completed.
module Tasks
    def after(timeout, options={}, &block)
        @_tasks_ ||= {}

        raise ArgumentError, "must provide a name" if !options[:name]
        
        task = {
            :init_time => Time.now.to_f,
            :wait_time => timeout,
            :block => block,
        }
        
        if !@_tasks_[options[:name]] || !options[:preserve]
            @_tasks_[options[:name]] = task
        end
    end

    def check_tasks
        return if !@_tasks_
        
        current_time = Time.now.to_f
        @_tasks_.reject! do |name, task|
            if current_time - task[:init_time] >= task[:wait_time]
                task[:block].call
                true
            else
                false
            end
        end
    end

    def task_exists?(name)
        return if !@_tasks_

        @_tasks_[name]
    end

    def task_time_remaining(name)
        return if !@_tasks_

        task = @_tasks_[name]
        current_time = Time.now.to_f

        raise "no such task" if !task

        task[:wait_time] - (current_time - task[:init_time])
    end
end


    
#
# A chingu trait providing timer-methods to its includer, examples:
# during(300) { @color = Color.new(0xFFFFFFFF) } # forces @color to white ever update for 300 ms
# after(400) { self.destroy! } # destroy object after 400 ms
# between(1000,2000) { self.rotate(10) } # starting after 1 second, call rotate(10) each update during 1 second
#
# All the above can be combined with a 'then { do_something }'. For example, a classic shmup damage effect:
# during(100) { @color.alpha = 100 }.then { @color.alpha = 255 }
#
module Timer
    def setup_timers
        #
        # Timers are saved as an array of arrays where each entry contains:
        # [start_time, end_time (or nil if one-shot), &block]
        #
        @_timers = Array.new
        @_repeating_timers = Array.new
    end
    
    def during(time, &block)
        ms = Gosu::milliseconds()
        @_last_timer = [ms, ms + time, block]
        @_timers << @_last_timer
        self
    end
    
    def after(time, &block)
        ms = Gosu::milliseconds()
        @_last_timer = [ms + time, nil, block]
        @_timers << @_last_timer
        self
    end
    
    def between(start_time, end_time, &block)
        ms = Gosu::milliseconds()
        @_last_timer = [ms + start_time, ms + end_time, block]
        @_timers << @_last_timer
        self
    end
    
    def then(&block)
        # ...use one-shots start_time for our trailing "then".
        # ...use durable timers end_time for our trailing "then".
        start_time = @_last_timer[1].nil? ? @_last_timer[0] : @_last_timer[1]
        @_timers << [start_time, nil, block]
    end
    
    def every(delay, &block)
        ms = Gosu::milliseconds()
        @_repeating_timers << [ms + delay, delay, block]
    end
    
    def update_trait
        ms = Gosu::milliseconds()
        
        @_timers.each do |start_time, end_time, block|
            block.call if ms > start_time && (end_time == nil || ms < end_time)
        end
        
        index = 0
        @_repeating_timers.each do |start_time, delay, block|
            if ms > start_time
                block.call
                @_repeating_timers[index] = [ms + delay, delay, block]
            end
            index += 1
        end
        
        # Remove one-shot timers (only a start_time, no end_time) and all timers which have expired
        @_timers.reject! { |start_time, end_time, block| (ms > start_time && end_time == nil) || (end_time != nil && ms > end_time) }
        
        super
    end
    
end

class FPSCounter
  attr_reader :fps
  
  def initialize
    @current_second = Gosu::milliseconds / 1000
    @accum_fps = 0
    @fps = 0
  end
  
  def register_tick
    @accum_fps += 1
    current_second = Gosu::milliseconds / 1000
    if current_second != @current_second
      @current_second = current_second
      @fps = @accum_fps
      @accum_fps = 0
    end
  end
end
