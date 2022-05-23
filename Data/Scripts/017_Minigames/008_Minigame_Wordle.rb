################################################################################
# "Wordle" mini-game
# By eriedaberrie
# Based on https://www.nytimes.com/games/wordle/index.html by Josh Wardle
#-------------------------------------------------------------------------------
# Run with:      pbWordle(darkmode?)
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

  def initialize(darkmode = true)
    @darkMode = darkmode
    @directory = "Graphics/Pictures/Wordle/#{@darkMode ? 'dark/' : 'light/'}"
  end

  def pbNewGame
    # initialize variables
    @sprites = {}
    @index_x = 0
    @index_y = 0
    @largeIndex_x = 0

    @squares = []
    @letters = []

    @guesses = []
    @guessNum = 0
    @letterNum = 0
    @curGuess = []
    # false - no data, 0 - DNE, 1 - yellow, 2 - green
    @keyData = Array.new(26, false)

    # not game over
    @ongoing = true
    @lost = false # for the share button

    @word = ANSWERS.sample

    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    pbCreateSprites
    pbFadeInAndShow(@sprites)

    # pbMessage(pbToWord(@word))
  end

  def pbCreateSprites
    @sprites[:bg] = Sprite.new(@viewport)
    @sprites[:bg].bitmap = RPG::Cache.load_bitmap(@directory, "boardbg")
    @sprites[:curtain] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites[:curtain].z = 99999
    @sprites[:curtain].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites[:curtain].opacity = 0
    @sprites[:cursorSmall] = Sprite.new(@viewport)
    @sprites[:cursorSmall].bitmap = RPG::Cache.load_bitmap(@directory, "cursorSmall")
    @sprites[:cursorSmall].x = 62
    @sprites[:cursorSmall].y = 254
    @sprites[:cursorSmall].z = 99998
    @sprites[:cursorLarge] = Sprite.new(@viewport)
    @sprites[:cursorLarge].bitmap = RPG::Cache.load_bitmap(@directory, "cursorLarge")
    @sprites[:cursorLarge].x = 62
    @sprites[:cursorLarge].y = 332
    @sprites[:cursorLarge].z = 99998
    @sprites[:cursorLarge].visible = false
    @sprites[:keyboardLetters] = Sprite.new(@viewport)
    @sprites[:keyboardLetters].bitmap = RPG::Cache.load_bitmap(@directory, "keyboardLetters")
    @sprites[:keyboardLetters].x = 64
    @sprites[:keyboardLetters].y = 256
    @sprites[:keyboardLetters].z = 10
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
    # @cursorSmall = [[@directory + "cursorSmall", 62, ,0, 0, 28, 36]]
    # @cursorLarge = [[@directory + "cursorLarge", 62, 332, 0, 0, 188, 40]]
    # pbDrawImagePositions(@sprites[:cursor].bitmap, @cursorSmall)
  end

  def getInput
    if @ongoing
      if Input.trigger?(Input::MOUSELEFT)
        mousepos = Mouse.getMousePos
        return if mousepos.nil?
        if mousepos[1] > 334 && mousepos[1] < 370
          if mousepos[0] > 64 && mousepos[0] < 248
            pbEnter
          elsif mousepos[0] > 264 && mousepos[0] < 448
            pbBackspace
          end
        elsif mousepos[1] > 256 && mousepos[1] < 326 && !(mousepos[1] > 288 && mousepos[1] < 294) &&
              mousepos[0] > 64 && mousepos[0] < 448 && (mousepos[0] % 30 > 4 && mousepos[0] % 30 < 28)
          pbAddLetter((mousepos[0] - 64) / 30, (mousepos[1] < 294) ? 0 : 1)
        end
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE
        case @index_y
        when 0
          @index_y = 2
          if @index_x < 6
            @largeIndex_x = 0
            @sprites[:cursorLarge].x = 62
          elsif @index_x > 6
            @largeIndex_x = 1
            @sprites[:cursorLarge].x = 262
          end
          @sprites[:cursorSmall].visible = false
          @sprites[:cursorLarge].visible = true
        when 2
          @index_y = 1
          @sprites[:cursorSmall].y = 292
          @sprites[:cursorLarge].visible = false
          @sprites[:cursorSmall].visible = true
        else
          @index_y = 0
          @sprites[:cursorSmall].y = 254
        end
      elsif Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        case @index_y
        when 1
          @index_y = 2
          if @index_x < 6
            @largeIndex_x = 0
            @sprites[:cursorLarge].x = 62
          elsif @index_x > 6
            @largeIndex_x = 1
            @sprites[:cursorLarge].x = 262
          end
          @sprites[:cursorSmall].visible = false
          @sprites[:cursorLarge].visible = true
        when 2
          @index_y = 0
          @sprites[:cursorSmall].y = 254
          @sprites[:cursorLarge].visible = false
          @sprites[:cursorSmall].visible = true
        else
          @index_y = 1
          @sprites[:cursorSmall].y = 292
        end
      elsif Input.repeat?(Input::LEFT)
        pbPlayCursorSE
        if @index_y == 2
          if @largeIndex_x == 0
            @largeIndex_x = 1
            @sprites[:cursorLarge].x = 262
          else
            @largeIndex_x = 0
            @sprites[:cursorLarge].x = 62
          end
        elsif @index_x == 0
          @index_x = 12
          @sprites[:cursorSmall].x = 422
        else
          @index_x -= 1
          @sprites[:cursorSmall].x -= 30
        end
      elsif Input.repeat?(Input::RIGHT)
        pbPlayCursorSE
        if @index_y == 2
          if @largeIndex_x == 0
            @largeIndex_x = 1
            @sprites[:cursorLarge].x = 262
          else
            @largeIndex_x = 0
            @sprites[:cursorLarge].x = 62
          end
        elsif @index_x == 12
          @index_x = 0
          @sprites[:cursorSmall].x = 62
        else
          @index_x += 1
          @sprites[:cursorSmall].x += 30
        end
      elsif Input.trigger?(Input::USE)
        # if cursor is on the bottom "action row"
        if @index_y == 2
          if @largeIndex_x == 0
            pbEnter
          else
            pbBackspace
          end
        else
          pbAddLetter(@index_x, @index_y)
        end
      elsif Input.trigger?(Input::ACTION)
        pbEnter
      elsif Input.trigger?(Input::BACK)
        pbBackspace
      elsif Input.repeat?(Input::BACK)
        @sprites[:curtain].opacity = 100
        if pbConfirmMessageSerious(_INTL("Are you sure you want to quit?"))
          @quit = true
          pbMessage(_INTL("The word was {1}.", pbToWord(@word)))
        else
          @sprites[:curtain].opacity = 0
        end
      end
    elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
      pbEndOptions
    end

    # debug
    # pbMessage(pbToWord(@word)) if Input.trigger?(Input::SPECIAL)

    # warning animation gradually gets dimmer but shouldn't interfere with getting input
    @sprites[:warn].opacity -= 10 if @sprites[:warn].opacity > 0
  end

  def pbAddLetter(x, y)
    if @letterNum == 5
      @sprites[:warn].opacity = 250
    else
      pbSEPlay("Voltorb Flip tile")

      newletter = x + (13 * y)
      @curGuess[@letterNum] = newletter
      @letters.push(["#{@directory}letters", 156 + (40 * @letterNum), 10 + (40 * @guessNum), 40 * newletter, 0, 40, 40])
      pbDrawImagePositions(@sprites[:letters].bitmap, @letters)
      @letterNum += 1
    end
  end

  def pbEnter
    if @letterNum < 5 || !(ANSWERS.include?(@curGuess))
      @sprites[:warn].opacity = 250
    else
      pbSEPlay("Voltorb Flip tile")
      @sprites[:warn].opacity = 0

      # false - no matches, 0 - yellow, 1 - green
      worddata = [false, false, false, false, false]
      5.times do |i|
        if @word[i] == @curGuess[i]
          worddata[i] = 1
          @keyData[@curGuess[i]] = 2
        else
          if @word.include?(@curGuess[i])
            @keyData[@curGuess[i]] ||= 1
          else
            @keyData[@curGuess[i]] = 0
          end
          5.times do |j|
            worddata[j] ||= 0 if @word[i] == @curGuess[j]
          end
        end
      end

      5.times do |i|
        pbSEPlay("Voltorb Flip point") if worddata[i] == 1

        square = ["#{@directory}tiles", 156 + (40 * i), 10 + (40 * @guessNum), 240, 0, 40, 40]
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
          if @keyData[letter]
            keys.push(["#{@directory}keys", 64 + (30 * x), 256 + (38 * y), (2 - @keyData[letter]) * 24, 0, 24, 32])
          end
        end
      end
      @sprites[:keys].bitmap.clear
      pbDrawImagePositions(@sprites[:keys].bitmap, keys)

      @guesses.push(worddata)
      @curGuess = []
      @letterNum = 0
      @guessNum += 1
      @sprites[:warn].y += 40

      if worddata.all? { |z| z == 1 }
        @ongoing = false
        @sprites[:curtain].opacity = 100
        pbMessage(_INTL("\\me[Voltorb Flip win]You win!\\wtnp[40]"))
        @sprites[:cursorSmall].visible = false
        @sprites[:cursorLarge].visible = false
        @sprites[:curtain].opacity = 0
      elsif @guessNum == 6
        @ongoing = false
        @lost = true
        @sprites[:curtain].opacity = 100
        pbMessage(_INTL("\\me[Voltorb Flip game over]You failed to guess the word {1}.\\wtnp[50]", pbToWord(@word)))
        @sprites[:cursorSmall].visible = false
        @sprites[:cursorLarge].visible = false
        @sprites[:curtain].opacity = 0
      end
    end
  end

  def pbBackspace
    if @letterNum == 0
      @sprites[:warn].opacity = 250
    else
      pbSEPlay("Voltorb Flip tile")

      @curGuess.pop
      @letters.pop
      @sprites[:letters].bitmap.clear
      pbDrawImagePositions(@sprites[:letters].bitmap, @letters)
      @letterNum -= 1
    end
  end

  def pbToWord(arr)
    ret = ""
    arr.each { |letter| ret += (letter + 65).chr }
    return ret
  end

  def pbEndOptions
    @sprites[:curtain].opacity = 100
    case pbShowCommands(nil, ["Cancel", "Share", "New Game", "Quit"], 1)
    when 0
      @sprites[:curtain].opacity = 0
    when 1
      begin
        ret = _INTL("||{1}|| {2}/6\n", pbToWord(@word), @lost ? "X" : @guessNum)
        @guesses.each do |guess|
          ret += "\n"
          guess.each do |i|
            case i
            when 0
              ret += "🟨"
            when 1
              ret += "🟩"
            else
              ret += @darkMode ? "⬛" : "⬜"
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
      pbNewGame
    when 3
      @quit = true
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      getInput
      break if @quit
    end
  end
end

class WordleScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbNewGame
    @scene.pbScene
    @scene.pbEndScene
  end
end

def pbWordle(darkmode = nil)
  darkmode = pbConfirmMessage(_INTL("Dark Mode?")) if darkmode.nil?
  pbFadeOutIn do
    scene = Wordle.new(darkmode)
    screen = WordleScreen.new(scene)
    screen.pbStartScreen
  end
end
