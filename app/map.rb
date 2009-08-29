
class Map
    WIDTH = 1022
    HEIGHT = 768
    
    def initialize(window)
        @window = window

        # background image
        @@nebula_textures ||= [Gosu::Image.new(@window, "#{MEDIA}/witchhead.png"),
                               Gosu::Image.new(@window, "#{MEDIA}/horsehead.png"),
                              ]
        @nebula = @@nebula_textures.random
        @nebula_theta = 0

        reset
    end

    def reset
        # base image for our lunar landscape
        @@image ||= TexPlay::create_blank_image(@window, WIDTH, HEIGHT)

        # clear the image for the next round
        @@image.rect 0, 0, @@image.width - 1, @@image.height - 1, :color => :alpha,
        :fill => true

        # textures to fill the landscae
        @@land_textures ||= [Gosu::Image.new(@window, "#{MEDIA}/crack2.png"),
                          Gosu::Image.new(@window, "#{MEDIA}/snow.png"),
                          Gosu::Image.new(@window, "#{MEDIA}/mud1.png"),
                          Gosu::Image.new(@window, "#{MEDIA}/crack3.png"),
                          Gosu::Image.new(@window, "#{MEDIA}/sand1.png"),
                          Gosu::Image.new(@window, "#{MEDIA}/rough1.png"),
                         ]

        @moonscape = @@land_textures.random
                          

        # now let's create the landscape
        points = []
        (0..WIDTH + 120).step(90) {  |x|
            p = Point.new
            p.x = x
            p.y = HEIGHT - rand * 600
            if p.y >= HEIGHT - 1 
                p.y = HEIGHT - 1
            end
            points << p
        }

        mag = rand(50) + 10
        rough = 2 + rand(20)
        spike = 2 + rand(14)
        period = 2 * rand + 0.2
        @@image.move_to(points.first.x, points.first.y)

        # plain beziers are boring, so let's augment it with a randomized sine wave
        @@image.bezier points, :color => :white,  :color_control => proc {  |c, t, y|
            y +=  mag * Math::sin(t * period * Math::PI / 180)
#            y +=  mag2 * Math::cos(t * period2 * Math::PI / 180)
            if (t % rough == 0 ) then
                @@image.line_to(t, y + rand * spike - (spike / 2), :texture => @moonscape)
            end
            :none
        }
            
        @@image.fill 300, 760, :texture => @moonscape
    end

    def solid?(x, y)
        return false if x < 0 || x > (WIDTH - 1) || y < 0 || y > (HEIGHT - 1)
        
        # a pixel is solid if the alpha channel is not 0
        @@image.get_pixel(x, y) && @@image.get_pixel(x, y)[3] != 0
    end

    def draw
        @nebula_theta += 0.015
        @nebula.draw_rot(512, 384, 0, @nebula_theta)

        # MELTLOL
#         x = rand(@@image.width)
#         y = rand(@@image.height)
#         @@image.splice(@@image, x, y + 1, :crop => [x, y, x + 110, y + 110] )
        @@image.draw(0, 0, 1)
    end

    def blast(x, y, radius)

        # draw a shadow
        @@image.circle x, y, radius + 10,  :fill => true, :shadow => true
        @@image.circle x, y, radius, :color => :alpha, :fill => true
    end
end
