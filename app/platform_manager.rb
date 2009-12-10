class PlatformManager
    
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @platforms = []
    end

    def add_platform(options = {})

        # if type isn't provided choose a random Platform
        plat_class = options[:type] || [YellowPlatform, RedPlatform, GreenPlatform, BluePlatform].random

        # if type is an array of Platform types, then select one randomly from the array
        plat_class = plat_class.random if plat_class.is_a?(Array)
        
        plat = plat_class.new(Win, @playgame, options[:x], options[:y])
        plat.set_into_place
        @platforms << plat
    end

    def each(&block)
        @platforms.each &block
    end

    def any?(&block)
        @platforms.any? &block
    end
    
    def reset
        @platforms = []
    end

    def update
        @platforms.delete_if { |plat|
            plat.update == false
        }
    end

    def draw
        @platforms.each { |plat|
            plat.draw
        }
    end
end    
