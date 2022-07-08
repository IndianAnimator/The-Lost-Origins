#===============================================================================
# "Unown invaders" mini-game
# By IndianAnimator
#-------------------------------------------------------------------------------
# Run with:      pbBulletHell()
#===============================================================================

class BulletHell
  DIRECTORY = "Graphics/Pictures/Bullet_Hell/"

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def initialize(pkmn_choice = 0)
    @pkmn_choice = pkmn_choice
  end

  def new_game
    # initialize variables
    @sprites = {}
    @index_x = 0
    @index_y = 0
    @player = 0

    # not game over
    @ongoing = true

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    create_sprites
    player_choice
    pbFadeInAndShow(@sprites)
  end

  def create_sprites
    @sprites[:bg] = Sprite.new(@viewport)
    @sprites[:bg].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "bg")
    @sprites[:curtain] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites[:curtain].z = 99999
    @sprites[:curtain].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites[:curtain].opacity = 0
    @sprites[:player] = Sprite.new(@viewport)
    @sprites[:player].x = Graphics.width / 2
    @sprites[:player].y = Graphics.height - 16
    @sprites[:player].z = 99997
    @sprites[:bullets] = Sprite.new(@viewport)
    @sprites[:bullets].x = 99999
  end

  def player_choice
    case @pkmn_choice
    when 0
      @sprites[:player].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "BULBASAUR")
      @sprites[:bullets].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "bulletseed")
      @resttime= 40
    when 1
      @sprites[:player].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "CHARMANDER")
      @sprites[:bullets].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "flamethrower")
      @resttime = 0
    when 2
      @sprites[:player].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "SQUIRTLE")
      @sprites[:bullets].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "bubbles")
      @resttime= 20
    end
  end

  def bullet
    last_shot = 0
    if Graphics.frame_rate - last_shot >  @resttime
      last_shot = Graphics.frame_rate
      Bullet.new(@x, @y, target_x, target_y).fire(100)
    end
  end

  def special

  end

  def get_input
    if @ongoing
      if Input.trigger?(Input::UP)
      elsif Input.trigger?(Input::LEFT)
        @sprites[:player].x += 16
      elsif Input.trigger?(Input::RIGHT)
        @sprites[:player].x -= 16
      elsif Input.trigger?(Input::USE)
      elsif Input.trigger?(Input::BACK)
        @sprites[:curtain].opacity = 100
        if pbConfirmMessageSerious(_INTL("Are you sure you want to quit?"))
          @quit = true
        else
          @sprites[:curtain].opacity = 0
        end
      end
    elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
      end_options
    end
  end

  def end_scene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def scene
    loop do
      Graphics.update
      Input.update
      get_input
      break if @quit
    end
  end
end

class BulletHellScreen
  def initialize(scene)
    @scene = scene
  end

  def start_screen
    @scene.new_game
    @scene.scene
    @scene.end_scene
  end
end

#main code for running minigame (unown invaders)

def pbBulletHell(pkmn_choice=nil)
  pkmn_choice = pbShowCommands(nil, ["Bulbasaur", "Charmander", "Squirtle"], 1) if pkmn_choice.nil?
  pbFadeOutIn do
    scene = BulletHell.new(pkmn_choice)
    screen = BulletHellScreen.new(scene)
    screen.start_screen
  end
end
