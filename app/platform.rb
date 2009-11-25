
class Platform
    include BoundingBox 
    
    attr_accessor :x, :y

    def initialize(window, playgame, screen, x, y)
        @x, @y = x, y
        @window = window
        @playgame = playgame
        @screen = screen

        @@image ||= Gosu::Image.new(@window, "#{MEDIA}/platform.png")

        set_bounding_box(@@image.width, @@image.height)
    end

    def screen
        @playgame.map.init_screen + @screen
    end

    def image
        @@image
    end

    def set_into_place
        @playgame.map.create_screen_at(@screen) if !@playgame.map.screen_images[@screen]
        self.y += 1 until @playgame.map.screen_images[@screen].solid?(self.x + (self.width / 2), self.y + (self.height))
        @playgame.objects << self
    end

    def update
        while !@playgame.map.solid?(self.x + (self.width / 2), self.y + (self.height))
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
        @@image.draw(@x, @y, 1)
    end
end
