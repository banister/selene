
class Meteor
    include BoundingBox 
    
    attr_reader :vx, :vy, :x, :y
    
    CUR_DIREC = File.dirname(__FILE__)   

    def initialize(window, playgame, x, y, image = nil)
        @x, @y = x, y
        @vx = 4 * rand - 2
        @vy = 2 * rand 
        @theta = 360 * rand
        @dtheta = 5 * rand * (rand(2) == 0 ? -1 : 1)
        @window = window
        @playgame = playgame

        @@roid_textures ||= [Gosu::Image.new(window, "#{CUR_DIREC}/media/roid.png"), Gosu::Image.new(window, "#{CUR_DIREC}/media/roidbig.png")]

        @collide_sound = Gosu::Sample.new(@window, "#{CUR_DIREC}/media/collide.ogg")

        # TODO: LOOK AT IT!@!!!
        if !image then
            selector = @playgame.level / 100
            selector = 0.4 if selector > 0.4
            
            @roid_type = rand() < (0.9 - selector) ? 0 : 1
            @image = @@roid_textures[@roid_type]
        else
            @image = image
            @roid_type = 0
        end

        case @roid_type
        when 0
            @blast_size = 30
            @blast_damage = 10
        when 1
            @blast_size = 50
            @blast_damage = 50
        end
        
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

        # delete meteor if it careens off screen
        elsif 
            @x > 0 && @x < Map::WIDTH - 1 && @y > -60 && @y < Map::HEIGHT - 1
        else
            true
        end
    end

    def draw
        @image.draw_rot(@x, @y, 1, @theta)
    end
    
end
