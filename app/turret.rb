
class Turret
    include BoundingBox
    include Tasks
    
    attr_accessor :x, :y

    def initialize(window, playgame, x, y)
        @x, @y = x, y
        @window = window
        @playgame = playgame

        @@image ||= Gosu::Image.new(@window, "#{MEDIA}/turret.png")
        @@barrel ||= Gosu::Image.new(@window, "#{MEDIA}/barrel.png")
        @barrel_theta = 0

        set_bounding_box(@@image.width, @@image.height)
    end

    def image
        @@image
    end

    def set_into_place
        while !@playgame.map.solid?(self.x, self.y + (self.height / 2))
            break if self.y > Map::HEIGHT
            self.y += 1
        end
    end

    def update
        while !@playgame.map.solid?(self.x, self.y + (self.height / 2))
            break if self.y > Map::HEIGHT
            self.y += 1
        end

        @playgame.lander.impulse(0, -0.1) if intersect?(@playgame.lander)

      #  if !task_exists?(:target_timeout)
      #      new_task(:wait => 2, :name => :target_timeout) do
                @locate_target = true
                dx = @playgame.lander.x - @x
                dy = @playgame.lander.y - @y
                target_vector = Vector[dx, dy].normalize
                @target_theta = ((Math.asin(target_vector[0]) / Math::PI) * 180)
       #     end
       # end
        locate_target
    end

    def locate_target
        return if !@locate_target

        @barrel_theta += 1 if @target_theta > @barrel_theta 
        @barrel_theta -= 1 if @target_theta < @barrel_theta 
        @locate_target = false if (@barrel_theta - @target_theta).abs < 1
        true
    end

    def solid?(x, y)
        x = x - self.x
        y = y - self.y
        return false if x < 0 || x > (image.width - 1) || y < 0 || y > (image.height - 1)
        
        # a pixel is solid if the alpha channel is not 0
        image.get_pixel(x, y) && image.get_pixel(x, y)[3] != 0
    end

    def width
        @@image.width
    end

    def height
        @@image.height
    end

    def warp(x, y)
        @x, @y = x, y
    end

    def draw
        @@barrel.sdraw_rot(@x, @y - @@image.height / 2 + 4, 1, @barrel_theta, 0.5, 1)
        @@image.sdraw_rot(@x, @y, 1, 0)
    end
end
