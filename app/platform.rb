
class Platform
    include BoundingBox 
    
    attr_accessor :x, :y

    def initialize(window, playgame, x, y)
        @x, @y = x, y
        @window = window
        @playgame = playgame

        config

        set_bounding_box(@image.width, @image.height)
    end

    def image
        @image
    end

    def set_into_place
        while !@playgame.map.solid?(self.x + (self.width / 2), self.y + (self.height) - 10)
            break if self.y > Map::HEIGHT
            self.y += 1
        end
    end

    def update
        while !@playgame.map.solid?(self.x + (self.width / 2), self.y + (self.height) - 10)
            break if self.y > Map::HEIGHT
            self.y += 1
        end
    end

    def solid?(x, y)
        x = x - self.x
        y = y - self.y
        return false if x < 0 || x > (image.width - 1) || y < 0 || y > (image.height - 1)
        
        # a pixel is solid if the alpha channel is not 0
        image.get_pixel(x, y) && image.get_pixel(x, y)[3] != 0
    end

    def landing_action(lander)
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

    def draw
        @image.sdraw(@x, @y, 1)
    end
end

class YellowPlatform < Platform
    def self.image
        @image ||= Gosu::Image.new(Win, "#{MEDIA}/yellowplatform.png")
    end
    
    def config
        @image = self.class.image
    end

    def landing_action(lander)
        lander.got_shield(1)
    end
end

class GreenPlatform < Platform
    def self.image
        @image ||= Gosu::Image.new(Win, "#{MEDIA}/greenplatform.png")
    end
    
    def config
        @image = self.class.image
    end

    def landing_action(lander)
        lander.unload_astronauts_over_time
    end
end

class RedPlatform < Platform
    def self.image
        @image ||= Gosu::Image.new(Win, "#{MEDIA}/redplatform.png")
    end
        
    def config
        @image = self.class.image
    end
end

class BluePlatform < Platform
    def self.image
        @image ||= Gosu::Image.new(Win, "#{MEDIA}/blueplatform.png")
    end
    
    def config
        @image = self.class.image
    end

    def landing_action(lander)
        lander.refuel_over_time
    end
end
