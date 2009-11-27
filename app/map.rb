
class Map
    WIDTH = 1022
    HEIGHT = 768

    attr_accessor :current_screen, :current_screen_image
    attr_reader :init_screen

    def initialize(window)
        @window = window

        # background image
        @@nebula_textures ||= [Gosu::Image.new(@window, "#{MEDIA}/witchhead.png"),
                               Gosu::Image.new(@window, "#{MEDIA}/horsehead.png"),
                              ]
        
        @nebula = @@nebula_textures.random
        @nebula_theta = 0

        @@land_textures ||= [Gosu::Image.new(@window, "#{MEDIA}/crack2.png"),
                             Gosu::Image.new(@window, "#{MEDIA}/snow.png"),
                             Gosu::Image.new(@window, "#{MEDIA}/mud1.png"),
                             Gosu::Image.new(@window, "#{MEDIA}/crack3.png"),
                             Gosu::Image.new(@window, "#{MEDIA}/sand1.png"),
                             Gosu::Image.new(@window, "#{MEDIA}/rough1.png"),
                            ]


        @screens = []
        @blank_screen = TexPlay.create_blank_image(@window, WIDTH, HEIGHT)

        1.times { create_screen }
        @init_screen = 0

        @current_screen = 0
    end

    def screen_images
        @screens
    end

    def create_screen_at(pos)
        if !@screens[pos] 
            create_screen(:right) until @screens[pos]
        end
    end

    def create_screen(position=:right)
        puts "creating a screen"
        # base image for our lunar landscape
        image = TexPlay::create_blank_image(@window, WIDTH, HEIGHT)
        puts "..created blank!"
        puts "..starting drawing!"

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
        image.move_to(points.first.x, points.first.y)

        # plain beziers are boring, so let's augment it with a randomized sine wave
        image.bezier points, :color => :white,  :color_control => proc {  |c, t, y|
            y +=  mag * Math::sin(t * period * Math::PI / 180)
            if (t % rough == 0 ) then
                image.line_to(t, y + rand * spike - (spike / 2), :texture => @moonscape)
            end
            :none
        }
            

        image.bezier [rand(500), 600, rand(100), 700, rand(800), 800, rand(300), 750 ], :closed => true
                image.fill 300, 760, :texture => @moonscape


        
        puts "..finished drawing!"

        case position
        when :left
            @screens.unshift image

            # keep track of where initial (0) screen is in the array
            @init_screen += 1 
        when :right
            @screens.push image
        end

        puts "...finished creating screen!"
    end

    def current_screen_image
        case @current_screen
        when nil
            @blank_screen
        else
            @screens[@current_screen]
        end
    end

    def change_screen_to(which_screen)
        case which_screen
        when :right
            if @current_screen == @screens.length - 1
                create_screen(:right)
            end
            @current_screen += 1 if @current_screen
        when :left
            if @current_screen == 0
                create_screen(:left)
            else
                @current_screen -= 1 if @current_screen
            end
        when :bottom
            @current_screen = @saved_screen_index
            
        when :top
            @saved_screen_index = @current_screen if @current_screen
            @current_screen = nil
        end
    end
    
    def solid?(x, y)
        return false if x < 0 || x > (WIDTH - 1) || y < 0 || y > (HEIGHT - 1)
        
        # a pixel is solid if the alpha channel is not 0
        current_screen_image.get_pixel(x, y) && current_screen_image.get_pixel(x, y)[3] != 0
    end

    def draw
        @nebula_theta += 0.015
        @nebula.draw_rot(512, 384, 0, @nebula_theta)

        # MELTLOL
#         x = rand(current_screen.width)
#         y = rand(current_screen.height)
#         current_screen.splice(current_screen, x, y + 1, :crop => [x, y, x + 110, y + 110] )
         current_screen_image.draw(0, 0, 1)
    end

    def blast(x, y, radius)

        # draw a shadow
        current_screen_image.circle x, y, radius + 10,  :fill => true, :shadow => true
        current_screen_image.circle x, y, radius, :color => :alpha, :fill => true
    end
end
