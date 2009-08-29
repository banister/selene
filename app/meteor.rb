
class Meteor
    include BoundingBox 
    
    attr_reader :vx, :vy, :x, :y
    
    def initialize(window, playgame, x, y, image = nil)
        @x, @y = x, y
        @vx = 4 * rand - 2
        @vy = 2 * rand 
        @theta = 360 * rand
        @dtheta = 5 * rand * (rand(2) == 0 ? -1 : 1)
        @window = window
        @playgame = playgame

        @collide_sound = Gosu::Sample.new(@window, "#{MEDIA}/collide.ogg")
        
        @image = image

        config
#        raise "a valid image was not received" if @@image

        set_bounding_box(@image.width, @image.height)
    end

    def update

        if !@playgame.is_movement_frozen?
            @x += @vx
            @y += @vy
            @vy += PlayGame::Gravity
            @theta += @dtheta
        end

        if @playgame.map.solid?(x, y) then
                      
            @playgame.map.blast(x, y, @blast_size)
          
            @collide_sound.play(1.0)
            
            5.times {
                @playgame.objects << Particle.new(@window, @x - 25 + rand(51),
                                                @y - 25 + rand(51))
            }

            false
        elsif @playgame.lander.shield_intersect?(self) then
            @playgame.lander.shield_hit(self)

            
            false
        elsif intersect?(@playgame.lander) then
            @playgame.lander.meteor_hit(self, @blast_damage)

            false
        elsif @x < 0 || @x > Map::WIDTH - 1 || @y < -60 || @y > Map::HEIGHT - 1
            false
        else
            true
        end
    end

    def draw
        @image.draw_rot(@x, @y, 1, @theta)
    end
end

class Wreckage < Meteor
    def config
        @blast_size = 20
        @blast_damage = 10
    end
end

class SmallMeteor < Meteor
    def config
        @blast_size = 30
        @blast_damage = 10
        @image ||= Gosu::Image.new(@window, "#{MEDIA}/roid.png")
    end
end

class LargeMeteor < Meteor
    def config
        @blast_size = 70
        @blast_damge = 50
        @image ||= Gosu::Image.new(@window, "#{MEDIA}/roidbig.png")
    end
end
