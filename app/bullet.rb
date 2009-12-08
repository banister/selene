class Bullet
    include BoundingBox

    attr_reader :vx, :vy
    attr_accessor :x, :y

    def initialize(playgame, x, y, vel, angle)
        angle -= 90
        @playgame = playgame
        @x, @y = x, y

        @vx = vel * Math::cos(angle.to_radians)
        @vy = vel * Math::sin(angle.to_radians)        

        @@image ||= TexPlay.create_image(Win, 10, 10).circle 5, 5, 4, :color => :red, :fill => true
        set_bounding_box(@@image.width, @@image.height)
    end

    def update
        @x += @vx
        @y += @vy

        if intersect?(@playgame.lander)
            @playgame.lander.object_hit(self, 100, 0.4)
            false
        elsif @x >= 2000 || @y < 0 || @x < 0
            false
        elsif @playgame.map.solid?(@x, @y)
            @playgame.map.blast(@x, @y, 30)
            5.times {
                @playgame.objects << Particle.new(Win, @x - 25 + rand(51),
                                                @y - 25 + rand(51))
            }
            
            false
        end
    end

    def draw
        @@image.sdraw_rot(@x, @y, 0, 0)
    end
end
