class PlatformManager
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @platforms = []
    end

    def add_platform(options = {})
        plat = Platform.new(@window, @playgame, options[:screen], options[:x], options[:y])
        plat.set_into_place
        @platforms << plat
    end

    
    def reset
        @playgame.objects.delete_if { |v| v.is_a?(Platform) }
        self
    end

    def screen_is(screen)
        @playgame.objects.delete_if { |v|
            v.is_a?(Platform) && v.screen != screen
        }

        @playgame.objects += @platforms.select { |v| v.screen == screen }
    end

    def update; end
end    
