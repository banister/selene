class Particle

    def initialize(window, x, y, options={})
        # All Particle instances use the same image
        @@image ||= Gosu::Image.new(window, "#{MEDIA}/smoke.png", false)

        @x, @y = x, y
        @dtheta = 0
        @theta = 0
        
        @options = {
            :direction => :up,
            :scale => 1,
            :speed => 2,
            :spread => 3,
            :color => [255, 255, 255, 255],
            :image => @@image,
            :rotate => false,
            :lifespan => 1
            
        }.merge!(options)
        @color = Gosu::Color.new(*@options[:color])

        if @options[:direction] == :random
            angle = 2 * Math::PI * rand
            @yinc = Math::sin(angle)
            @xinc = Math::cos(angle)
        end

        if @options[:rotate]
            @dtheta = rand(3) - 1
        end
        
        @image = @options[:image]
    end
    
    def update
        case @options[:direction]
        when :up
            @y -= @options[:speed]
            @x = @x - @options[:spread] / 2 + rand(@options[:spread])
        when :down
            @y += @options[:speed]
            @x = @x - @options[:spread] / 2 + rand(@options[:spread])
        when :left
            @x -= @options[:speed]
            @y = @y - @options[:spread] / 2 + rand(@options[:spread])
        when :right
            @x += @options[:speed]
            @y = @y - @options[:spread] / 2 + rand(@options[:spread])
        when :random
            @x += @xinc * @options[:speed] - @options[:spread] / 2 + rand(@options[:spread])
            @y += @yinc * @options[:speed] - @options[:spread] / 2 + rand(@options[:spread])
        end

        # need the if block below or Gosu freaks out when giving Color a negative number
        alpha_sub = 5 / @options[:lifespan]
        if @color.alpha - alpha_sub < 0
            @color.alpha = 0
        else
            @color.alpha -= alpha_sub
        end
        @color.alpha > 0
    end
    
    def draw
        @theta += @dtheta
        @image.draw_rot(@x, @y , 1, @theta, 0.5, 0.5,
                         @options[:scale], @options[:scale], @color)
    end
end
