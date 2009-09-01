class PowerUpManager
    def initialize(window, playgame)
        @window = window
        @playgame = playgame
        @difficulty = @playgame.difficulty
    end

    def update
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
