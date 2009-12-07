class Bullet
    include BoundingBox

    attr_accessor :x, :y

    def initialize(playgame, x, y, vel, angle)
        angle -= 90
        @playgame = playgame
        @x, @y = x, y

        @init_x = vel * Math::cos(angle.to_radians)
        @init_y = vel * Math::sin(angle.to_radians)        

        @@image ||= TexPlay.create_image(Win, 10, 10).circle 5, 5, 4, :color => :red, :fill => true
        set_bounding_box(@@image.width, @@image.height)
    end

    def update
        @x += @init_x
        @y += @init_y

        if intersect?(@playgame.lander)
            false
        elsif @x >= 2000 || @y < 0 || @x < 0
            false
        end
    end

    def draw
        @@image.sdraw_rot(@x, @y, 0, 0)
    end
end
