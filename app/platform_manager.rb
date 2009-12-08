class PlatformManager
    
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @platforms = []
    end

    def add_platform(options = {})
        plat = Platform.new(@window, @playgame, options[:x], options[:y])
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
