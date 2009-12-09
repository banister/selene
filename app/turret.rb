
class Turret
    include BoundingBox
    include Tasks

    HEALTH = 100
    Range = 500
    
    attr_accessor :x, :y, :health

    def initialize(window, playgame, x, y)
        @x, @y = x, y
        @window = window
        @playgame = playgame
        @health = HEALTH
        @health_meter = HealthMeter.new

        @@image ||= Gosu::Image.new(@window, "#{MEDIA}/turret.png")
        @image = @@image
        @@barrel ||= Gosu::Image.new(@window, "#{MEDIA}/barrel.png")
        @barrel_theta = 0

        set_bounding_box(@@image.width, @@image.height)
    end

    def image
        @image
    end

    def set_into_place
        while !@playgame.map.solid?(self.x, self.y + (self.height / 2))
            break if self.y > Map::HEIGHT
            self.y += 1
        end
    end

    def health=(h)
        h = 0 if h < 0 
        @health = h.to_i
        @health_meter.update_health_status(h.to_f / HEALTH)
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

    def target_in_range?
        dy = @playgame.lander.y - @y
        dx = @playgame.lander.x - @x
        dy < 0 && dx.abs <= Range
    end

    def track_target

        if target_in_range? && health > 0
            target_theta = Math.asin(target_vector[0]).to_degrees

            # shoot if lined up
            if (@barrel_theta - target_theta).abs < 1 
                before(2, :name => :bullet_timeout, :preserve => true) do
                    @playgame.objects << Bullet.new(@playgame, *barrel_tip, 2, @barrel_theta)
                end
            end
        else
            target_theta = 0
        end

        # update barrel angle
        @barrel_theta += (target_theta - @barrel_theta).sgn
        
        true
    end


    def object_hit(obj, damage)
        @image = @image.dup if @image == @@image
        self.health -= damage

        chunk_size = 40
        x = rand(@image.width)
        y = rand(@image.height)
        chunk = [x, y, x + chunk_size, y + chunk_size]
         @image.circle x, y, chunk_size / 2, :color_control => { :mult => [0.8, 0.8, 0.8, 1] }, :fill => true
        @image.splice @image, x - 4 + rand(7), y - 4 + rand(7),
        :crop => chunk,
         :color_control => proc { |c, c1|
             c1[0] /= 1.1
             c1[1] /= 1.1 
             c1[2] /= 1.1
            
             c1
         }
    end
    
    def solid?(x, y)
        x = x - self.x
        y = y - self.y
        return false if x < 0 || x > (image.width - 1) || y < 0 || y > (image.height - 1)
        
        # a pixel is solid if the alpha channel is not 0
        image.get_pixel(x, y) && image.get_pixel(x, y)[3] != 0
    end

    def width
        @image.width
    end

    def height
        @image.height
    end

    def warp(x, y)
        @x, @y = x, y
    end

    def barrel_tip
        y = @y - @image.height / 2 + 4
        barrel_length = @@barrel.height
        
        [@x + barrel_length * target_vector[0],
         y + barrel_length * target_vector[1]]
    end

    def draw
        @@barrel.sdraw_rot(@x, @y - @image.height / 2 + 4, 1, @barrel_theta, 0.5, 1)
        @image.sdraw_rot(@x, @y, 1, 0)
        @health_meter.sdraw_rot(@x, @y - @image.height / 2 - 5, 1, 0)
    end
end
