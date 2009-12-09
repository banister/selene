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

        @@image ||= TexPlay.create_blank_image(Win, 10, 10).circle 5, 5, 4, :color => :red, :fill => true
        set_bounding_box(@@image.width, @@image.height)
    end

    def update
        @x += @vx
        @y += @vy

        # collides with meteor?
        meteor = @playgame.meteor_manager.find { |m| m.point_intersect?(self) }
        if meteor
            meteor.active = false
            smoke_cloud
            return false
        end

        turret = @playgame.turret_manager.find { |t| t.point_intersect?(self) }
        if turret
            turret.object_hit(self, 20)
            smoke_cloud
            return false
        end

        # lander?
        if intersect?(@playgame.lander)
            @playgame.lander.object_hit(self, 100, 0.4)
            false

        # shield?
        elsif @playgame.lander.shield_intersect?(self) then
            @playgame.lander.shield_hit(self)
            false

        # screen?
        elsif @x >= @playgame.map.total_map_width || @y < 0 || @x < 0
            false

        # terrain?
        elsif @playgame.map.solid?(@x, @y)
            @playgame.map.blast(@x, @y, 30)
            smoke_cloud
            false
        end
    end

    def smoke_cloud
            5.times {
                @playgame.objects << Particle.new(Win, @x - 25 + rand(51),
                                                @y - 25 + rand(51))
            }
    end

    def draw
        @@image.sdraw_rot(@x, @y, 0, 0)
    end
end
