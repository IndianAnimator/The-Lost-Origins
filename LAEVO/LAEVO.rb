class PokemonPartyPanel < Sprite
  attr_reader :pokemon
  attr_reader :active
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :text

  TEXT_BASE_COLOR    = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR  = Color.new(40, 40, 40)
  HP_BAR_WIDTH       = 96
  STATUS_ICON_WIDTH  = 44
  STATUS_ICON_HEIGHT = 16

  def initialize(pokemon, index, viewport = nil)
    super(viewport)
    @pokemon = pokemon
    @active = (index == 0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
    self.x = (index % 2) * Graphics.width / 2
    self.y = (16 * (index % 2)) + (96 * (index / 2))
    @evoreqs = {}
    GameData::Species.get(@pokemon.species).get_evolutions(true).each do |evo|   # [new_species, method, parameter, boolean]
      if evo[1].to_s.start_with?('Item')
        @evoreqs[evo[0]] = evo[2] if $bag.has?(evo[2]) && @pokemon.check_evolution_on_use_item(evo[2])
      elsif evo[1].to_s.start_with?('Trade')
        @evoreqs[evo[0]] = evo[2] if $Trainer.has_species?(evo[2]) || @pokemon.check_evolution_on_trade(evo[2])
      elsif @pokemon.check_evolution_on_level_up
        @evoreqs[evo[0]] = nil
      end
    end
    @panelbgsprite = ChangelingSprite.new(0, 0, viewport)
    @panelbgsprite.z = self.z
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_round")
      @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_round_sel")
      @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_round_faint")
      @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_round_faint_sel")
      @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_round_swap")
      @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able", "Graphics/Pictures/Party/panel_rect")
      @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Party/panel_rect_sel")
      @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/panel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Party/panel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Party/panel_rect_swap")
      @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Party/panel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Party/panel_rect_swap_sel2")
    end
    @hpbgsprite = ChangelingSprite.new(0, 0, viewport)
    @hpbgsprite.z = self.z + 1
    @hpbgsprite.addBitmap("able", "Graphics/Pictures/Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted", "Graphics/Pictures/Party/overlay_hp_back_faint")
    @hpbgsprite.addBitmap("swap", "Graphics/Pictures/Party/overlay_hp_back_swap")
    @ballsprite = ChangelingSprite.new(0, 0, viewport)
    @ballsprite.z = self.z + 5
    if @evoreqs.length.positive?
      @ballsprite.addBitmap("desel","Plugins/LAEVO/Graphics/icon_ball")
      @ballsprite.addBitmap("sel","Plugins/LAEVO/Graphics/icon_ball_sel")
    else
      @ballsprite.addBitmap("desel","Graphics/Pictures/Party/icon_ball")
      @ballsprite.addBitmap("sel","Graphics/Pictures/Party/icon_ball_sel")
    end
    @pkmnsprite = PokemonIconSprite.new(pokemon, viewport)
    @pkmnsprite.setOffset(PictureOrigin::CENTER)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z + 6
    @helditemsprite = HeldItemIconSprite.new(0, 0, @pokemon, viewport)
    @helditemsprite.z = self.z + 3
    @overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    @overlaysprite.z = self.z + 4
    pbSetSystemFont(@overlaysprite.bitmap)
    @hpbar       = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @statuses    = AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
    @typeoverlay = AnimatedBitmap.new("Graphics/Pictures/Party/type_overlay")
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end

  def dispose
    @panelbgsprite.dispose
    @hpbgsprite.dispose
    @ballsprite.dispose
    @pkmnsprite.dispose
    @helditemsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @hpbar.dispose
    @statuses.dispose
    @typeoverlay.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def text=(value)
    return if @text == value
    @text = value
    @refreshBitmap = true
    refresh
  end

  def pokemon=(value)
    @pokemon = value
    @pkmnsprite.pokemon = value if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.pokemon = value if @helditemsprite && !@helditemsprite.disposed?
    @refreshBitmap = true
    refresh
  end

  def selected=(value)
    return if @selected == value
    @selected = value
    refresh
  end

  def preselected=(value)
    return if @preselected == value
    @preselected = value
    refresh
  end

  def switching=(value)
    return if @switching == value
    @switching = value
    refresh
  end

  def hp; return @pokemon.hp; end

  def refresh_panel_graphic
    return if !@panelbgsprite || @panelbgsprite.disposed?
    if self.selected
      if self.preselected
        @panelbgsprite.changeBitmap("swapsel2")
      elsif @switching
        @panelbgsprite.changeBitmap("swapsel")
      elsif @pokemon.fainted?
        @panelbgsprite.changeBitmap("faintedsel")
      else
        @panelbgsprite.changeBitmap("ablesel")
      end
    else
      if self.preselected
        @panelbgsprite.changeBitmap("swap")
      elsif @pokemon.fainted?
        @panelbgsprite.changeBitmap("fainted")
      else
        @panelbgsprite.changeBitmap("able")
      end
    end
    @panelbgsprite.x     = self.x
    @panelbgsprite.y     = self.y
    @panelbgsprite.color = self.color
  end

  def refresh_hp_bar_graphic
    return if !@hpbgsprite || @hpbgsprite.disposed?
    @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length > 0))
    return if !@hpbgsprite.visible
    if self.preselected || (self.selected && @switching)
      @hpbgsprite.changeBitmap("swap")
    elsif @pokemon.fainted?
      @hpbgsprite.changeBitmap("fainted")
    else
      @hpbgsprite.changeBitmap("able")
    end
    @hpbgsprite.x     = self.x + 96
    @hpbgsprite.y     = self.y + 50
    @hpbgsprite.color = self.color
  end

  def refresh_ball_graphic
    return if !@ballsprite || @ballsprite.disposed?
    @ballsprite.changeBitmap((self.selected) ? "sel" : "desel")
    @ballsprite.x     = self.x + 10
    @ballsprite.y     = self.y
    @ballsprite.color = self.color
  end

  def refresh_pokemon_icon
    return if !@pkmnsprite || @pkmnsprite.disposed?
    @pkmnsprite.x        = self.x + 60
    @pkmnsprite.y        = self.y + 40
    @pkmnsprite.color    = self.color
    @pkmnsprite.selected = self.selected
  end

  def refresh_held_item_icon
    return if !@helditemsprite || @helditemsprite.disposed? || !@helditemsprite.visible
    @helditemsprite.x     = self.x + 62
    @helditemsprite.y     = self.y + 48
    @helditemsprite.color = self.color
  end

  def refresh_overlay_information
    return if !@refreshBitmap
    @overlaysprite.bitmap&.clear
    draw_type
    draw_name
    draw_level
    draw_gender
    draw_hp
    draw_status
    draw_shiny_icon
    draw_annotation
  end

  def draw_name
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[@pokemon.name, 96, 22, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
  end

  def draw_level
    return if @pokemon.egg?
    # "Lv" graphic
    pbDrawImagePositions(@overlaysprite.bitmap,
                         [["Graphics/Pictures/Party/overlay_lv", 20, 70, 0, 0, 22, 14]])
    # Level number
    pbSetSmallFont(@overlaysprite.bitmap)
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[@pokemon.level.to_s, 42, 68, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
    pbSetSystemFont(@overlaysprite.bitmap)
  end

  def draw_gender
    return if @pokemon.egg? || @pokemon.genderless?
    gender_text  = (@pokemon.male?) ? _INTL("♂") : _INTL("♀")
    base_color   = (@pokemon.male?) ? Color.new(0, 112, 248) : Color.new(232, 32, 16)
    shadow_color = (@pokemon.male?) ? Color.new(120, 184, 232) : Color.new(248, 168, 184)
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[gender_text, 224, 22, 0, base_color, shadow_color]])
  end

  def draw_hp
    return if @pokemon.egg? || (@text && @text.length > 0)
    # HP numbers
    hp_text = sprintf("% 3d /% 3d", @pokemon.hp, @pokemon.totalhp)
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[hp_text, 224, 66, 1, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
    # HP bar
    if @pokemon.able?
      w = @pokemon.hp * HP_BAR_WIDTH / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2   # Round to the nearest 2 pixels
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      hprect = Rect.new(0, hpzone * 8, w, 8)
      @overlaysprite.bitmap.blt(128, 52, @hpbar.bitmap, hprect)
    end
  end

  def draw_status
    return if @pokemon.egg? || (@text && @text.length > 0)
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    return if status < 0
    statusrect = Rect.new(0, STATUS_ICON_HEIGHT * status, STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT)
    @overlaysprite.bitmap.blt(78, 68, @statuses.bitmap, statusrect)
  end

  def draw_type
    return if @pokemon.egg? || (@text && @text.length > 0)
    return unless (type = @pokemon.types[0])
    typenum = GameData::Type.get(type).icon_position
    typerect = Rect.new(0, 98 * typenum, 256, 98)
    @overlaysprite.bitmap.blt(0, 0, @typeoverlay.bitmap, typerect)
  end

  def draw_shiny_icon
    return if @pokemon.egg? || !@pokemon.shiny?
    pbDrawImagePositions(@overlaysprite.bitmap,
                         [["Graphics/Pictures/shiny", 80, 48, 0, 0, 16, 16]])
  end

  def draw_annotation
    return if !@text || @text.length == 0
    pbDrawTextPositions(@overlaysprite.bitmap,
                        [[@text, 96, 62, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]])
  end

  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    refresh_panel_graphic
    refresh_hp_bar_graphic
    refresh_ball_graphic
    refresh_pokemon_icon
    refresh_held_item_icon
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    refresh_overlay_information
    @refreshBitmap = false
    @refreshing = false
  end

  def update
    super
    @panelbgsprite.update if @panelbgsprite && !@panelbgsprite.disposed?
    @hpbgsprite.update if @hpbgsprite && !@hpbgsprite.disposed?
    @ballsprite.update if @ballsprite && !@ballsprite.disposed?
    @pkmnsprite.update if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.update if @helditemsprite && !@helditemsprite.disposed?
  end
end

MenuHandlers.add(:party_menu, :summary, {
  "name"      => _INTL("Summary"),
  "order"     => 10,
  "effect"    => proc { |screen, party, party_idx|
    screen.scene.pbSummary(party_idx) {
      screen.scene.pbSetHelpText((party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
    }
  }
})

MenuHandlers.add(:party_menu, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 20,
  "condition" => proc { |screen, party, party_idx| next $DEBUG },
  "effect"    => proc { |screen, party, party_idx|
    screen.pbPokemonDebug(party[party_idx], party_idx)
  }
})
MenuHandlers.add(:party_menu, :evolve, {
  "name"      => _INTL("Evolve"),
  "order"     => 30,
  "condition" => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    evoreqs = {}
    GameData::Species.get(pkmn.species).get_evolutions(true).each do |evo|   # [new_species, method, parameter, boolean]
      if evo[1].to_s.start_with?('Item')
        evoreqs[evo[0]] = evo[2] if $bag.has?(evo[2]) && pkmn.check_evolution_on_use_item(evo[2])
      elsif evo[1].to_s.start_with?('Trade')
        evoreqs[evo[0]] = evo[2] if $Trainer.has_species?(evo[2]) || pkmn.check_evolution_on_trade(evo[2])
      elsif pkmn.check_evolution_on_level_up
        evoreqs[evo[0]] = nil
      end
    end
    evoreqs.length.positive?},
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    evoreqs = {}
    GameData::Species.get(pkmn.species).get_evolutions(true).each do |evo|   # [new_species, method, parameter, boolean]
      if evo[1].to_s.start_with?('Item')
        evoreqs[evo[0]] = evo[2] if $bag.has?(evo[2]) && pkmn.check_evolution_on_use_item(evo[2])
      elsif evo[1].to_s.start_with?('Trade')
        evoreqs[evo[0]] = evo[2] if $Trainer.has_species?(evo[2]) || pkmn.check_evolution_on_trade(evo[2])
      elsif pkmn.check_evolution_on_level_up
        evoreqs[evo[0]] = nil
      end
    end
    case evoreqs.length
      when 0
        pbDisplay(_INTL("This Pokémon can't evolve."))
        next
      when 1
        newspecies = evoreqs.keys[0]
      else
        newspecies = evoreqs.keys[@scene.pbShowCommands(
          _INTL("Which species would you like to evolve into?"),
          evoreqs.keys.map { |id| _INTL(GameData::Species.get(id).real_name) }
        )]
      end
      if evoreqs[newspecies] # requires an item
        next unless @scene.pbConfirmMessage(_INTL(
          "This will consume a {1}. Do you want to continue?",
          GameData::Item.get(evoreqs[newspecies]).name
        ))
        $PokemonBag.pbDeleteItem(evoreqs[newspecies])
      end
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newspecies)
        evo.pbEvolution
        evo.pbEndScreen
        screen.pbRefresh
      }
  }
})

MenuHandlers.add(:party_menu, :switch, {
  "name"      => _INTL("Switch"),
  "order"     => 50,
  "condition" => proc { |screen, party, party_idx| next party.length > 1 },
  "effect"    => proc { |screen, party, party_idx|
    screen.scene.pbSetHelpText(_INTL("Move to where?"))
    old_party_idx = party_idx
    party_idx = screen.scene.pbChoosePokemon(true)
    screen.pbSwitch(old_party_idx, party_idx) if party_idx >= 0 && party_idx != old_party_idx
  }
})

MenuHandlers.add(:party_menu, :mail, {
  "name"      => _INTL("Mail"),
  "order"     => 60,
  "condition" => proc { |screen, party, party_idx| next !party[party_idx].egg? && party[party_idx].mail },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    command = screen.scene.pbShowCommands(_INTL("Do what with the mail?"),
                                          [_INTL("Read"), _INTL("Take"), _INTL("Cancel")])
    case command
    when 0   # Read
      pbFadeOutIn {
        pbDisplayMail(pkmn.mail, pkmn)
        screen.scene.pbSetHelpText((party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      }
    when 1   # Take
      if pbTakeItemFromPokemon(pkmn, screen)
        screen.pbRefreshSingle(party_idx)
      end
    end
  }
})

MenuHandlers.add(:party_menu, :item, {
  "name"      => _INTL("Item"),
  "order"     => 70,
  "condition" => proc { |screen, party, party_idx| next !party[party_idx].egg? && !party[party_idx].mail },
  "effect"    => proc { |screen, party, party_idx|
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:party_menu_item, screen, party, party_idx) do |option, hash, name|
      command_list.push(name)
      commands.push(hash)
    end
    command_list.push(_INTL("Cancel"))
    # Choose a menu option
    choice = screen.scene.pbShowCommands(_INTL("Do what with an item?"), command_list)
    next if choice < 0 || choice >= commands.length
    commands[choice]["effect"].call(screen, party, party_idx)
  }
})

MenuHandlers.add(:party_menu_item, :use, {
  "name"      => _INTL("Use"),
  "order"     => 10,
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    item = screen.scene.pbUseItem($bag, pkmn) {
      screen.scene.pbSetHelpText((party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
    }
    next if !item
    pbUseItemOnPokemon(item, pkmn, screen)
    screen.pbRefreshSingle(party_idx)
  }
})

MenuHandlers.add(:party_menu_item, :give, {
  "name"      => _INTL("Give"),
  "order"     => 20,
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    item = screen.scene.pbChooseItem($bag) {
      screen.scene.pbSetHelpText((party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
    }
    next if !item || !pbGiveItemToPokemon(item, pkmn, screen, party_idx)
    screen.pbRefreshSingle(party_idx)
  }
})

MenuHandlers.add(:party_menu_item, :take, {
  "name"      => _INTL("Take"),
  "order"     => 30,
  "condition" => proc { |screen, party, party_idx| next party[party_idx].hasItem? },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    next if !pbTakeItemFromPokemon(pkmn, screen)
    screen.pbRefreshSingle(party_idx)
  }
})

MenuHandlers.add(:party_menu_item, :move, {
  "name"      => _INTL("Move"),
  "order"     => 40,
  "condition" => proc { |screen, party, party_idx| next party[party_idx].hasItem? && !party[party_idx].item.is_mail? },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    item = pkmn.item
    itemname = item.name
    screen.scene.pbSetHelpText(_INTL("Move {1} to where?", itemname))
    old_party_idx = party_idx
    moved = false
    loop do
      screen.scene.pbPreSelect(old_party_idx)
      party_idx = screen.scene.pbChoosePokemon(true, party_idx)
      break if party_idx < 0
      newpkmn = party[party_idx]
      break if party_idx == old_party_idx
      if newpkmn.egg?
        screen.pbDisplay(_INTL("Eggs can't hold items."))
        next
      elsif !newpkmn.hasItem?
        newpkmn.item = item
        pkmn.item = nil
        screen.scene.pbClearSwitching
        screen.pbRefresh
        screen.pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
        moved = true
        break
      elsif newpkmn.item.is_mail?
        screen.pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", newpkmn.name))
        next
      end
      # New Pokémon is also holding an item; ask what to do with it
      newitem = newpkmn.item
      newitemname = newitem.name
      if newitem == :LEFTOVERS
        screen.pbDisplay(_INTL("{1} is already holding some {2}.\1", newpkmn.name, newitemname))
      elsif newitemname.starts_with_vowel?
        screen.pbDisplay(_INTL("{1} is already holding an {2}.\1", newpkmn.name, newitemname))
      else
        screen.pbDisplay(_INTL("{1} is already holding a {2}.\1", newpkmn.name, newitemname))
      end
      next if !screen.pbConfirm(_INTL("Would you like to switch the two items?"))
      newpkmn.item = item
      pkmn.item = newitem
      screen.scene.pbClearSwitching
      screen.pbRefresh
      screen.pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
      screen.pbDisplay(_INTL("{1} was given the {2} to hold.", pkmn.name, newitemname))
      moved = true
      break
    end
    screen.scene.pbSelect(old_party_idx) if !moved
  }
})
