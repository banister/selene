class Astronaut
    include BoundingBox 
    
    attr_accessor :x, :y

    def initialize(window, playgame, screen, x, y)
        @x, @y = x, y
        @vx, @vy = 0, 0
        @window = window
        @playgame = playgame
        @screen = screen

        @@image ||= Gosu::Image.new(@window, "#{MEDIA}/mmstd.png")

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
        self.y += 1 until @playgame.map.screen_images[@screen].solid?(self.x, self.y + (self.height / 2))
        @playgame.objects << self
    end

    def update
        if !@playgame.map.solid?(self.x, self.y + (self.height / 2)) &&
                @playgame.map.current_screen_index == self.screen
            @vy += PlayGame::LandGravity
            @y += @vy
        else
            @vy = 0
        end

        if @playgame.lander.landed && intersect?(@playgame.lander) 
            false
        elsif @playgame.lander.landed
            dir = (@playgame.lander.x - x).sgn
            try_walk(dir) 
        end
    end

    def try_jump
        @vy = -12 if @playgame.map.solid?(x, y + 1)
    end
    
    def try_walk(dir)
        @dir = dir
        @y -= 2
        if !@playgame.map.solid?(x + dir, y) &&
                !@playgame.map.solid?(x - dir, y)
            @x += dir

        end
        2.times { @y += 1 unless @playgame.map.solid?(x, y + (self.height / 2) + 1) } 
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
        @@image.draw_rot(@x, @y, 1, 0)
    end
end
