class TurretManager
    
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @turrets = []
    end

    def add_turret(options = {})
        turret = Turret.new(@window, @playgame, options[:x], options[:y])
        turret.set_into_place
        @turrets << turret
    end

    def each(&block)
        @turrets.each &block
    end
    
    def reset
        @turrets = []
    end

    def update
        @turrets.delete_if { |turret|
            turret.update == false
        }
    end

    def draw
        @turrets.each { |turret|
            turret.draw
        }
    end
end    
