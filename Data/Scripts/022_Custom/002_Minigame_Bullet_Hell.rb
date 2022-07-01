class BulletHell
  DIRECTORY = "Graphics/Pictures/Bullet_Hell/"

  def update
    pbUpdateSpriteHash(@sprites)
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
    pbFadeInAndShow(@sprites)

    # pbMessage(to_word(@word))
  end

  def create_sprites
    @sprites[:bg] = Sprite.new(@viewport)
    @sprites[:bg].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "bg")
    @sprites[:curtain] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites[:curtain].z = 99999
    @sprites[:curtain].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites[:curtain].opacity = 0
    @sprites[:player] = Sprite.new(@viewport)
    @sprites[:player].x = 256
    @sprites[:player].y = 400
    @sprites[:bullets] = Sprite.new(@viewport)

    # default cursors
    # @cursor_small = [[DIRECTORY + "cursor_small", 62, ,0, 0, 28, 36]]
    # @cursor_large = [[DIRECTORY + "cursor_large", 62, 332, 0, 0, 188, 40]]
    # pbDrawImagePositions(@sprites[:cursor].bitmap, @cursor_small)
  end

  def pkmn_choice
    case pbShowCommands(nil, ["Bulbasaur", "Charmander", "Squirtle", "Quit"], 1)
    when 0
      @sprites[:player].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "BULBASAUR")
      @sprites[:bullets].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "bulletseed")
    when 1
      @sprites[:player].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "CHARMANDER")
      @sprites[:bullets].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "flamethrower")
    when 2
      @sprites[:player].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "SQUIRTLE")
      @sprites[:bullets].bitmap = RPG::Cache.load_bitmap(DIRECTORY, "bubbles")
    when 3
      @quit = true
    end
  end

  def get_input
    if @ongoing
      if Input.trigger?(Input::MOUSELEFT)
        mouse_pos = Mouse.getMousePos

      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE
        case @index_y
        when 0
          @index_y = 2
          if @index_x < 6
            @large_index_x = 0
            @sprites[:cursor_large].x = 62
          elsif @index_x > 6
            @large_index_x = 1
            @sprites[:cursor_large].x = 262
          end
          @sprites[:cursor_small].visible = false
          @sprites[:cursor_large].visible = true
        when 2
          @index_y = 1
          @sprites[:cursor_small].y = 292
          @sprites[:cursor_large].visible = false
          @sprites[:cursor_small].visible = true
        else
          @index_y = 0
          @sprites[:cursor_small].y = 254
        end
      elsif Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        case @index_y
        when 1
          @index_y = 2
          if @index_x < 6
            @large_index_x = 0
            @sprites[:cursor_large].x = 62
          elsif @index_x > 6
            @large_index_x = 1
            @sprites[:cursor_large].x = 262
          end
          @sprites[:cursor_small].visible = false
          @sprites[:cursor_large].visible = true
        when 2
          @index_y = 0
          @sprites[:cursor_small].y = 254
          @sprites[:cursor_large].visible = false
          @sprites[:cursor_small].visible = true
        else
          @index_y = 1
          @sprites[:cursor_small].y = 292
        end
      elsif Input.repeat?(Input::LEFT)
        pbPlayCursorSE
        if @index_y == 2
          if @large_index_x == 0
            @large_index_x = 1
            @sprites[:cursor_large].x = 262
          else
            @large_index_x = 0
            @sprites[:cursor_large].x = 62
          end
        elsif @index_x == 0
          @index_x = 12
          @sprites[:cursor_small].x = 422
        else
          @index_x -= 1
          @sprites[:cursor_small].x -= 30
        end
      elsif Input.repeat?(Input::RIGHT)
        pbPlayCursorSE
        if @index_y == 2
          if @large_index_x == 0
            @large_index_x = 1
            @sprites[:cursor_large].x = 262
          else
            @large_index_x = 0
            @sprites[:cursor_large].x = 62
          end
        elsif @index_x == 12
          @index_x = 0
          @sprites[:cursor_small].x = 62
        else
          @index_x += 1
          @sprites[:cursor_small].x += 30
        end
      elsif Input.trigger?(Input::USE)
        # if cursor is on the bottom "action row"
        if @index_y == 2
          if @large_index_x == 0
            enter
          else
            backspace
          end
        else
          add_letter(@index_x, @index_y)
        end
      elsif Input.trigger?(Input::ACTION)
        enter
      elsif Input.trigger?(Input::BACK)
        backspace
      elsif Input.repeat?(Input::BACK)
        @sprites[:curtain].opacity = 100
        if pbConfirmMessageSerious(_INTL("Are you sure you want to quit?"))
          @quit = true
          pbMessage(_INTL("The word was {1}.", to_word(@word)))
        else
          @sprites[:curtain].opacity = 0
        end
      end
    elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
      end_options
    end

    # debug
    # pbMessage(to_word(@word)) if Input.trigger?(Input::SPECIAL)

    # warning animation gradually gets dimmer but shouldn't interfere with getting input
    @sprites[:warn].opacity -= 10 if @sprites[:warn].opacity > 0
  end

  def add_letter(x, y)
    if @letter_num == 5
      @sprites[:warn].opacity = 250
    else
      pbSEPlay("Voltorb Flip tile")

      newletter = x + (13 * y)
      @cur_guess[@letter_num] = newletter
      @letters.push([
        "#{DIRECTORY}letters",
        156 + (40 * @letter_num),
        10 + (40 * @guess_num),
        40 * newletter, 0, 40, 40
      ])
      pbDrawImagePositions(@sprites[:letters].bitmap, @letters)
      @letter_num += 1
    end
  end

  def enter
    if @letter_num < 5 || !ANSWERS.include?(@cur_guess)
      @sprites[:warn].opacity = 250
    else
      pbSEPlay("Voltorb Flip tile")
      @sprites[:warn].opacity = 0

      # false - no matches, 0 - yellow, 1 - green
      worddata = [false, false, false, false, false]
      5.times do |i|
        if @word[i] == @cur_guess[i]
          worddata[i] = 1
          @key_data[@cur_guess[i]] = 2
        else
          if @word.include?(@cur_guess[i])
            @key_data[@cur_guess[i]] ||= 1
          else
            @key_data[@cur_guess[i]] = 0
          end
          5.times do |j|
            worddata[j] ||= 0 if @word[i] == @cur_guess[j]
          end
        end
      end

      5.times do |i|
        pbSEPlay("Voltorb Flip point") if worddata[i] == 1

        square = ["#{DIRECTORY}tiles", 156 + (40 * i), 10 + (40 * @guess_num), 240, 0, 40, 40]
        pbDrawImagePositions(@sprites[:animation].bitmap, [square])
        pbWait(Graphics.frame_rate / 10)

        @sprites[:animation].bitmap.clear
        square[3] = 280
        pbDrawImagePositions(@sprites[:animation].bitmap, [square])
        pbWait(Graphics.frame_rate / 10)

        @sprites[:animation].bitmap.clear
        square[3] = (worddata[i]) ? ((4 - worddata[i]) * 40) : 200
        pbDrawImagePositions(@sprites[:animation].bitmap, [square])
        pbWait(Graphics.frame_rate / 10)

        @sprites[:animation].bitmap.clear
        @sprites[:squares].bitmap.clear
        square[3] -= 120
        @squares.push(square)
        pbDrawImagePositions(@sprites[:squares].bitmap, @squares)
        pbWait(Graphics.frame_rate / 10)
      end

      keys = []
      13.times do |x|
        2.times do |y|
          letter = x + (13 * y)
          if @key_data[letter]
            keys.push(["#{DIRECTORY}keys", 64 + (30 * x), 256 + (38 * y), (2 - @key_data[letter]) * 24, 0, 24, 32])
          end
        end
      end
      @sprites[:keys].bitmap.clear
      pbDrawImagePositions(@sprites[:keys].bitmap, keys)

      @guesses.push(worddata)
      @cur_guess = []
      @letter_num = 0
      @guess_num += 1
      @sprites[:warn].y += 40

      if worddata.all? { |z| z == 1 }
        @ongoing = false
        @sprites[:curtain].opacity = 100
        pbMessage(_INTL("\\me[Voltorb Flip win]You win!\\wtnp[40]"))
        @sprites[:cursor_small].visible = false
        @sprites[:cursor_large].visible = false
        @sprites[:curtain].opacity = 0
      elsif @guess_num == 6
        @ongoing = false
        @lost = true
        @sprites[:curtain].opacity = 100
        pbMessage(_INTL("\\me[Voltorb Flip game over]You failed to guess the word {1}.\\wtnp[50]", to_word(@word)))
        @sprites[:cursor_small].visible = false
        @sprites[:cursor_large].visible = false
        @sprites[:curtain].opacity = 0
      end
    end
  end

  def backspace
    if @letter_num == 0
      @sprites[:warn].opacity = 250
    else
      pbSEPlay("Voltorb Flip tile")

      @cur_guess.pop
      @letters.pop
      @sprites[:letters].bitmap.clear
      pbDrawImagePositions(@sprites[:letters].bitmap, @letters)
      @letter_num -= 1
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

def pbBulletHell()
  pbFadeOutIn do
    scene = BulletHell.new
    screen = BulletHellScreen.new(scene)
    screen.start_screen
  end
end
