
class Map
    WIDTH = 1020
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
        @moonscape = @@land_textures.random

        8.times { create_screen }
    end

    def screen_images
        @screens
    end

    def total_map_width
        @screens.length * Map::WIDTH
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
        #image.rect 0,0, image.width - 1, image.height - 1, :color => :rand

        puts "..created blank!"
        puts "..starting drawing!"

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

        #image.line WIDTH - 1, 600, WIDTH - 1, HEIGHT - 1, :texture => @moonscape
        #image.line 0, 600, 0, HEIGHT - 1, :texture => @moonscape

        points.first.y = 600
        points.last.x = WIDTH - 1

        points.last.y = 600

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

        # ensure the bezier ends at this point (so next screen can join up nicely)
        image.line_to(points.last.x, points.last.y, :texture => @moonscape)
            
        #image.bezier [rand(500), 700, rand(100), 800, rand(800), 900, rand(300), 850 ], :closed => true
        image.fill 300, 760, :texture => @moonscape
        
        puts "..finished drawing!"

        case position
        when :left
            @screens.unshift image
        when :right
            @screens.push image
        end


        puts "...finished creating screen!"
    end

    def solid?(x, y)
        return false if x < 0 || x > (@screens.length * WIDTH - 1) ||
            y < 0 || y > (HEIGHT - 1)

        s = (x.to_i / WIDTH) 
        rx = x.to_i % WIDTH
        screen = @screens[s]
        
        # a pixel is solid if the alpha channel is not 0
        screen.get_pixel(rx, y) && screen.get_pixel(rx, y)[3] != 0
    end

    def white_out
        color = Gosu::Color.new(255, 255, 255, 255)
        window = Win
        Win.draw_quad(0, 0, color,
                         window.width, 0, color,
                         window.width, window.height, color,
                         0, window.height, color, 0, :default)
        
    end
    
    def draw
        @nebula_theta += 0.015
        @nebula.draw_rot(512, 384, 0, @nebula_theta)
        #white_out

#         MELTLOL
#          x = rand(current_screen.width)
#          y = rand(current_screen.height)
#                  current_screen.splice(current_screen, x, y + 1, :crop => [x, y, x + 110, y + 110] )
        @screens.each_with_index { |v, i|
            v.sdraw(i * (WIDTH - 1), 0, 1)
        }
        #current_screen_image.draw(0, 0, 1)
    end


    def blast(x, y, radius)
        s = (x.to_i / WIDTH) 
        rx = x.to_i % WIDTH
        screen = @screens[s]
                

        # draw a shadow
        crater = lambda {         #puts "solid check, matched against screen #{s}"

            circle rx, y, radius + 10,  :fill => true, :shadow => true
            circle rx, y, radius, :color => :alpha, :fill => true
        }

        screen.paint &crater

        if rx + radius > WIDTH
            rx = rx - WIDTH
            @screens[s + 1].paint &crater if s < @screens.length - 1
        elsif rx - radius < 0
            rx = rx + WIDTH
            @screens[s - 1].paint &crater if s >= 1
        end
    end
end
