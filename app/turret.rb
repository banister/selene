
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
        check_tasks
        while !@playgame.map.solid?(self.x, self.y + (self.height / 2))
            break if self.y > Map::HEIGHT
            self.y += 1
        end

        @playgame.lander.impulse(0, -0.2) if intersect?(@playgame.lander)

        track_target
    end

    def target_vector
        dx = @playgame.lander.x - @x
        dy = @playgame.lander.y - @y
        Vector[dx, dy].normalize
    end

    def track_target
        dy = @playgame.lander.y - @y
        target_theta = Math.asin(target_vector[0]).to_degrees
        target_theta = 0 if dy > 0
        
        @barrel_theta += 1 if target_theta > @barrel_theta 
        @barrel_theta -= 1 if target_theta < @barrel_theta
        
        if (@barrel_theta - target_theta).abs < 1 && dy < 0
            after(2, :name => :bullet_timeout, :preserve => true) do
                b = Bullet.new(@playgame, *barrel_tip, 2, @barrel_theta)
                @playgame.objects << b
            end
        end
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

    def barrel_tip
        y = @y - @@image.height / 2 + 4
        barrel_length = @@barrel.height
        
        [@x + barrel_length * target_vector[0],
         y + barrel_length * target_vector[1]]
    end

    def draw
        @@barrel.sdraw_rot(@x, @y - @@image.height / 2 + 4, 1, @barrel_theta, 0.5, 1)
        @@image.sdraw_rot(@x, @y, 1, 0)
    end
end
