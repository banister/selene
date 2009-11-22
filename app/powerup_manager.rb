class PowerUpManager
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @difficulty = @playgame.difficulty
        @on = false
    end

    def start
        @on = true
        self
    end

    def stop
        @on = false
        self
    end

    def reset
        @playgame.objects.delete_if { |v| v.is_a?(PowerUp) }
        self
    end

    def update
        return if !@on
        
        if rand < @difficulty.refuel_factor then
            @playgame.objects << RocketJuice.new(@window, @playgame, 1024 * rand, rand(400))
        end

        if rand < @difficulty.quantum_engine_factor then
            @playgame.objects << QuantumEngine.new(@window, @playgame, 1024 * rand, rand(400))
        end

        if rand < @difficulty.shield_factor then
            @playgame.objects << Shield.new(@window, @playgame, 1024 * rand, rand(400))
        end

        if rand < @difficulty.freeze_factor then
            @playgame.objects << Freeze.new(@window, @playgame, 1024 * rand, rand(400))
        end
    end
end    
