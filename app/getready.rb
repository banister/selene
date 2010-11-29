class GetReady
  attr_reader :applaud
  
  def initialize(window, level, applaud = nil)
    @window = window
    @level = level
    @applaud = applaud
    
    @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
  end

  def draw
    if @applaud == :success
      @font.draw("Well done!", 290, 200, 3, 5.0, 5.0, 0xff00dd00)
    elsif @applaud == :failure
      @font.draw("Too bad!", 290, 200, 3, 5.0, 5.0, 0xffdd0000)
    end
    @font.draw("Get Ready for level #{@level}!", 50, 300, 3, 5.0, 5.0, 0xffffff00)
    @font.draw("(press space)", 270, 400, 3, 4.0, 4.0, 0xdddddddd)
  end

  def update
  end
  
  def name
    :getready
  end

  def level_complete?
    false
  end

  def level_fail?
    false
  end
end
