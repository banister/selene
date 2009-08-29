class Particle

    def initialize(window, x, y, options={})
        # All Particle instances use the same image
        @@image ||= Gosu::Image.new(window, "#{MEDIA}/smoke.png", false)
        
        @x, @y = x, y
        @options = {
            :direction => :up,
            :scale => 1,
            :speed => 2,
            :spread => 3,
            :color => [255, 255, 255, 255]
        }.merge!(options)
        @color = Gosu::Color.new(*@options[:color])
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
        end
        # Remove if faded completely.
        @color.alpha -= 5
        @color.alpha > 0
    end
    
    def draw
        @@image.draw_rot(@x, @y , 1, 0, 0.5, 0.5,
                         @options[:scale], @options[:scale], @color)
    end
end
