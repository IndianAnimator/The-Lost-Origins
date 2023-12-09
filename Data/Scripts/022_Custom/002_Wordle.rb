################################################################################
# "Wordle" mini-game
# By eriedaberrie
# Based on https://www.nytimes.com/games/wordle/index.html by Josh Wardle
#-------------------------------------------------------------------------------
# Run with:      pbWordle(dark_mode?)
################################################################################
class Wordle
    # rubocop:disable all
  
    # All words are lined up in numbers below
    # Pokemon: Absol, Aipom, Arbok, Azelf, Bagon, Budew, Burmy, Deino, Ditto, Doduo, Eevee, Ekans, Entei, Gible, Gloom, Golem, Goomy, Hoopa, Hypno, Inkay, Klang, Klink, Kubfu, Lotad, Lugia, Luxio, Magby,
    # Minun, Numel, Paras, Pichu, Ralts, Riolu, Rotom, Shinx, Snivy, Tepig, Throh, Toxel, Unown, Yanma, Zorua, Zubat 43 words
    # Types: Demon, Fairy, Grass, Steel, Water 48 words
    # Abilities: Trace, Minus, Blaze, Swarm, Stall, Klutz, Frisk, Moody, Moxie, Gooey, Ripen, As One 61 words
    # Moves: Lunge, U-turn, Thief, Snarl, Fling, Taunt, Spark, Charm, Pluck, Defog, Roost, Curse, Spite, Spore, Stomp, Covet, Round, Swift, Pound, Flail, Block, Flash, Glare, Growl, Toxic, Clamp 87 words
    # a b c d e f g h i j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
    # 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
    ANSWERS = [
      [0,1,18,14,11],[0,8,15,14,12],[0,17,1,14,10],[0,25,4,11,5],[1,0,6,14,13],[1,20,3,4,22],[1,20,17,12,24],[3,4,8,13,14],[3,8,19,19,14],[3,14,3,20,14],[4,4,21,4,4],[4,10,0,13,18],[4,13,19,4,8],[6,8,1,11,4],[6,11,14,14,12],[6,14,11,4,12],[6,14,14,12,24],[7,14,14,15,0],[7,24,15,13,14],[8,13,10,0,24],[10,11,0,13,6],[10,11,8,13,10],[10,20,1,5,20],[11,14,19,0,3],[11,20,6,8,0],[11,20,23,8,14],[12,0,6,1,24],[12,8,13,20,13],[13,20,12,4,11],[15,0,17,0,18],[15,8,2,7,20],[17,0,11,19,18],[17,8,14,11,20],[17,14,19,14,12],[18,7,8,13,23],[18,13,8,21,24],[19,4,15,8,6],[19,7,17,14,7],[19,14,23,4,11],[20,13,14,22,13],[24,0,13,12,0],[25,14,17,20,0],[25,20,1,0,19],[3,4,12,14,13],[5,0,8,17,24],[6,17,0,18,18],[18,19,4,4,11],[22,0,19,4,17],[19,17,0,2,4],[12,8,13,20,18],[1,11,0,25,4],[18,22,0,17,12],[18,19,0,11,11],[10,11,20,19,25],[5,17,8,18,10],[12,14,14,3,24],[12,14,23,8,4],[6,14,14,4,24],[17,8,15,4,13],[0,18,14,13,4],[11,20,13,6,4],[20,19,20,17,13],[19,7,8,4,5],[18,13,0,17,11],[5,11,8,13,6],[19,0,20,13,19],[18,15,0,17,10],[2,7,0,17,12],[15,11,20,2,10],[3,4,5,14,6],[17,14,14,18,19],[2,20,17,18,4],[18,15,8,19,4],[18,15,14,17,4],[18,19,14,12,15],[2,14,21,4,19],[17,14,20,13,3],[18,22,8,5,19],[15,14,20,13,3],[5,11,0,8,11],[1,11,14,2,10],[5,11,0,18,7],[6,11,0,17,4],[6,17,14,22,11],[19,14,23,8,2],[2,11,0,12,15]
    ]
  
    # rubocop:enable all
  
    def update
      pbUpdateSpriteHash(@sprites)
    end
  
    def initialize(dark_mode = true)
      @dark_mode = dark_mode
      @directory = "Graphics/UI/Wordle/#{@dark_mode ? 'dark/' : 'light/'}"
    end
  
    def new_game
      # initialize variables
      @sprites = {}
      @index_x = 0
      @index_y = 0
      @large_index_x = 0
  
      @squares = []
      @letters = []
  
      @guesses = []
      @guess_num = 0
      @letter_num = 0
      @cur_guess = []
      # false - no data, 0 - DNE, 1 - yellow, 2 - green
      @key_data = Array.new(26, false)
  
      # not game over
      @ongoing = true
      @lost = false # for the share button
  
      @word = ANSWERS.sample
  
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      create_sprites
      pbFadeInAndShow(@sprites)
  
      # pbMessage(to_word(@word))
    end
  
    def create_sprites
      @sprites[:bg] = Sprite.new(@viewport)
      @sprites[:bg].bitmap = RPG::Cache.load_bitmap(@directory, "boardbg")
      @sprites[:curtain] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[:curtain].z = 99999
      @sprites[:curtain].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      @sprites[:curtain].opacity = 0
      @sprites[:cursor_small] = Sprite.new(@viewport)
      @sprites[:cursor_small].bitmap = RPG::Cache.load_bitmap(@directory, "cursorSmall")
      @sprites[:cursor_small].x = 62
      @sprites[:cursor_small].y = 254
      @sprites[:cursor_small].z = 99998
      @sprites[:cursor_large] = Sprite.new(@viewport)
      @sprites[:cursor_large].bitmap = RPG::Cache.load_bitmap(@directory, "cursorLarge")
      @sprites[:cursor_large].x = 62
      @sprites[:cursor_large].y = 332
      @sprites[:cursor_large].z = 99998
      @sprites[:cursor_large].visible = false
      @sprites[:keyboard_letters] = Sprite.new(@viewport)
      @sprites[:keyboard_letters].bitmap = RPG::Cache.load_bitmap(@directory, "keyboardLetters")
      @sprites[:keyboard_letters].x = 64
      @sprites[:keyboard_letters].y = 256
      @sprites[:keyboard_letters].z = 10
      @sprites[:squares] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[:letters] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[:letters].z = 10
      @sprites[:keys] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[:warn] = Sprite.new(@viewport)
      @sprites[:warn].bitmap = RPG::Cache.load_bitmap(@directory, "warn")
      @sprites[:warn].x = 156
      @sprites[:warn].y = 10
      @sprites[:warn].z = 20
      @sprites[:warn].opacity = 0
      @sprites[:animation] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites[:animation].z = 99999
  
      # default cursors
      # @cursor_small = [[@directory + "cursor_small", 62, ,0, 0, 28, 36]]
      # @cursor_large = [[@directory + "cursor_large", 62, 332, 0, 0, 188, 40]]
      # pbDrawImagePositions(@sprites[:cursor].bitmap, @cursor_small)
    end
  
    def get_input
      if @ongoing
        if Input.trigger?(Input::MOUSELEFT)
          mouse_pos = Mouse.getMousePos
          return if mouse_pos.nil?
          if mouse_pos[1] > 334 && mouse_pos[1] < 370
            if mouse_pos[0] > 64 && mouse_pos[0] < 248
              enter
            elsif mouse_pos[0] > 264 && mouse_pos[0] < 448
              backspace
            end
          elsif mouse_pos[1] > 256 && mouse_pos[1] < 326 && !(mouse_pos[1] > 288 && mouse_pos[1] < 294) &&
                mouse_pos[0] > 64 && mouse_pos[0] < 448 && (mouse_pos[0] % 30 > 4 && mouse_pos[0] % 30 < 28)
            add_letter((mouse_pos[0] - 64) / 30, (mouse_pos[1] < 294) ? 0 : 1)
          end
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
          "#{@directory}letters",
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
  
          square = ["#{@directory}tiles", 156 + (40 * i), 10 + (40 * @guess_num), 240, 0, 40, 40]
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
              keys.push(["#{@directory}keys", 64 + (30 * x), 256 + (38 * y), (2 - @key_data[letter]) * 24, 0, 24, 32])
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
  
    def to_word(arr)
      ret = ""
      arr.each { |letter| ret << (letter + 65).chr }
      return ret
    end
  
    def end_options
      @sprites[:curtain].opacity = 100
      case pbShowCommands(nil, ["Cancel", "Share", "New Game", "Quit"], 1)
      when 0
        @sprites[:curtain].opacity = 0
      when 1
        begin
          ret = _INTL("||{1}|| {2}/6\n", to_word(@word), @lost ? "X" : @guess_num)
          @guesses.each do |guess|
            ret << "\n"
            guess.each do |i|
              case i
              when 0
                ret << "🟨"
              when 1
                ret << "🟩"
              else
                ret << (@dark_mode ? "⬛" : "⬜")
              end
            end
          end
          Input.clipboard = ret
          pbMessage(_INTL("\\me[Voltorb Flip win]Copied to clipboard!\\wtnp[40]"))
        rescue MKXPError, EncodingError
          pbMessage(_INTL("\\me[Voltorb Flip game over]Failed to copy to clipboard.\\wtnp[40]"))
        end
        @sprites[:curtain].opacity = 0
      when 2
        pbDisposeSpriteHash(@sprites)
        new_game
      when 3
        @quit = true
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
  
  class WordleScreen
    def initialize(scene)
      @scene = scene
    end
  
    def start_screen
      @scene.new_game
      @scene.scene
      @scene.end_scene
    end
  end
  
  def pbWordle(dark_mode = nil)
    dark_mode = pbConfirmMessage(_INTL("Dark Mode?")) if dark_mode.nil?
    pbFadeOutIn do
      scene = Wordle.new(dark_mode)
      screen = WordleScreen.new(scene)
      screen.start_screen
    end
  end
  