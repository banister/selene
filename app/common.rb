MEDIA = File.dirname(__FILE__) + '/media'

Point = Struct.new(:x, :y)

## monkey patches to core classes 
class Numeric
    def round_to(n=0)
        return self.to_i if n == 0
        
        ((self * (10 ** n)).to_i) / (10 ** n).to_f
    end

    def sgn
        self <=> 0
    end
end

class Array
    def random
        self[rand(size)]
    end
end
## end monkey patches

class Gosu::Image
    def solid?(x, y)
        return false if x < 0 || x > (self.width - 1) || y < 0 || y > (self.height - 1)
        
        # a pixel is solid if the alpha channel is not 0
        self.get_pixel(x, y) && self.get_pixel(x, y)[3] != 0
    end
end

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
end

# inspired by phelps (Deathly Dimensions)
# tasks NEED a name so that new (updated) tasks can overwrite their older versions that have
# not yet completed.
module Tasks
    def new_task(options={}, &block)
        @_tasks_ ||= {}

        raise ArgumentError, "must provide a wait time" if !options[:wait]
        raise ArgumentError, "must provide a name" if !options[:name]

        task = {
            :init_time => Time.now.to_f,
            :wait_time => options[:wait],
            :block => block,
        }
        
        @_tasks_[options[:name]] = task
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
