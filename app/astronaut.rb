class Astronaut
  include BoundingBox 
  
  attr_accessor :x, :y

  Range = 500

  def initialize(window, playgame, x, y)
    @x, @y = x, y
    @vx, @vy = 0, 0
    @window = window
    @playgame = playgame
    @dir = 1

    @@image ||= Gosu::Image.new(@window, "#{MEDIA}/mmstd.png")

    set_bounding_box(@@image.width, @@image.height)
  end

  def image
    @@image
  end

  def set_into_place
    while !@playgame.map.solid?(self.x, self.y + (self.height / 2))
      break if self.y > Map::HEIGHT
      self.y += 1
    end
  end

  def lander_in_range?
    dx = @playgame.lander.x - @x
    dx.abs <= Range
  end
  
  def update
    if !@playgame.map.solid?(self.x, self.y + (self.height / 2))
      @vy += PlayGame::LandGravity
      @y += @vy
    else
      @vy = 0
    end

    if @playgame.lander.landed && intersect?(@playgame.lander)
      @playgame.lander.got_astronaut
      false
    elsif @playgame.lander.landed && lander_in_range?
      dir = (@playgame.lander.x - x).sgn
      try_walk(dir) 
    end
  end

  def try_jump
    @vy = -12 if @playgame.map.solid?(x, y + 1)
  end
  
  def try_walk(dir)
    @dir = dir
    @y -= 2
    @x += dir / 2.0 if !@playgame.map.solid?(x + dir, y) 
    2.times { @y += 1 unless @playgame.map.solid?(x, y + (self.height / 2) + 1) } 
  end

  def solid?(x, y)
    x = x - self.x
    y = y - self.y
    return false if x < 0 || x > (image.width - 1) || y < 0 || y > (image.height - 1)
    
    # a pixel is solid if the alpha channel is not 0
    image.get_pixel(x, y) && image.get_pixel(x, y)[3] != 0
  end

  def width
    @@image.width
  end

  def height
    @@image.height
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def draw
    @@image.sdraw_rot(@x, @y, 1, 0, 0.5, 0.5, @dir)
  end
end
