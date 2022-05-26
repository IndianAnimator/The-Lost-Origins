#===============================================================================
# "v20 Hotfixes" plugin
# This file contains fixes for bugs in Essentials v20.
# These bug fixes are also in the master branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

Essentials::ERROR_TEXT += "[v20 Hotfixes 1.0.1]\r\n"

#===============================================================================
# Fixed incorrect message when choosing a Pokémon to withdraw from Day Care.
#===============================================================================
class DayCare
  def self.choose(message, choice_var)
    day_care = $PokemonGlobal.day_care
    case day_care.count
    when 0
      raise _INTL("No Pokémon found in Day Care to choose from.")
    when 1
      day_care.slots.each_with_index { |slot, i| $game_variables[choice_var] = i if slot.filled? }
    else
      commands = []
      indices = []
      day_care.slots.each_with_index do |slot, i|
        choice_text = slot.choice_text
        next if !choice_text
        commands.push(choice_text)
        indices.push(i)
      end
      commands.push(_INTL("CANCEL"))
      command = pbMessage(message, commands, commands.length)
      $game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
    end
  end
end

#===============================================================================
# Fixed event evolutions not working.
#===============================================================================
class Pokemon
  def check_evolution_by_event(value = 0)
    return check_evolution_internal { |pkmn, new_species, method, parameter|
      success = GameData::Evolution.get(method).call_event(pkmn, parameter, value)
      next (success) ? new_species : nil
    }
  end
end

#===============================================================================
# Fixed incorrect status condition icon used for fainted Pokémon and Pokémon
# with Pokérus.
#===============================================================================
class PokemonPartyPanel < SpriteWrapper
  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
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
    if @hpbgsprite && !@hpbgsprite.disposed?
      @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length > 0))
      if @hpbgsprite.visible
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
    end
    if @ballsprite && !@ballsprite.disposed?
      @ballsprite.changeBitmap((self.selected) ? "sel" : "desel")
      @ballsprite.x     = self.x + 10
      @ballsprite.y     = self.y
      @ballsprite.color = self.color
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x        = self.x + 60
      @pkmnsprite.y        = self.y + 40
      @pkmnsprite.color    = self.color
      @pkmnsprite.selected = self.selected
    end
    if @helditemsprite&.visible && !@helditemsprite.disposed?
      @helditemsprite.x     = self.x + 62
      @helditemsprite.y     = self.y + 48
      @helditemsprite.color = self.color
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    if @refreshBitmap
      @refreshBitmap = false
      @overlaysprite.bitmap&.clear
      basecolor   = Color.new(248, 248, 248)
      shadowcolor = Color.new(40, 40, 40)
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos = []
      # Draw Pokémon name
      textpos.push([@pokemon.name, 96, 22, 0, basecolor, shadowcolor])
      if !@pokemon.egg?
        if !@text || @text.length == 0
          # Draw HP numbers
          textpos.push([sprintf("% 3d /% 3d", @pokemon.hp, @pokemon.totalhp), 224, 66, 1, basecolor, shadowcolor])
          # Draw HP bar
          if @pokemon.hp > 0
            w = @pokemon.hp * 96 / @pokemon.totalhp.to_f
            w = 1 if w < 1
            w = ((w / 2).round) * 2
            hpzone = 0
            hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
            hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
            hprect = Rect.new(0, hpzone * 8, w, 8)
            @overlaysprite.bitmap.blt(128, 52, @hpbar.bitmap, hprect)
          end
          # Draw status
          status = -1
          if @pokemon.fainted?
            status = GameData::Status.count - 1
          elsif @pokemon.status != :NONE
            status = GameData::Status.get(@pokemon.status).icon_position
          elsif @pokemon.pokerusStage == 1
            status = GameData::Status.count
          end
          if status >= 0
            statusrect = Rect.new(0, 16 * status, 44, 16)
            @overlaysprite.bitmap.blt(78, 68, @statuses.bitmap, statusrect)
          end
        end
        # Draw gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"), 224, 22, 0, Color.new(0, 112, 248), Color.new(120, 184, 232)])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"), 224, 22, 0, Color.new(232, 32, 16), Color.new(248, 168, 184)])
        end
        # Draw shiny icon
        if @pokemon.shiny?
          pbDrawImagePositions(@overlaysprite.bitmap,
                               [["Graphics/Pictures/shiny", 80, 48, 0, 0, 16, 16]])
        end
      end
      pbDrawTextPositions(@overlaysprite.bitmap, textpos)
      # Draw level text
      if !@pokemon.egg?
        pbDrawImagePositions(@overlaysprite.bitmap,
                             [["Graphics/Pictures/Party/overlay_lv", 20, 70, 0, 0, 22, 14]])
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,
                            [[@pokemon.level.to_s, 42, 68, 0, basecolor, shadowcolor]])
      end
      # Draw annotation text
      if @text && @text.length > 0
        pbSetSystemFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,
                            [[@text, 96, 62, 0, basecolor, shadowcolor]])
      end
    end
    @refreshing = false
  end
end

class PokemonSummary_Scene
  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg
      return
    end
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos = []
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    imagepos.push([ballimage, 14, 60])
    # Show status/fainted/Pokérus infected icon
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    if status >= 0
      imagepos.push(["Graphics/Pictures/statuses", 124, 100, 0, 16 * status, 44, 16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage == 2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"), 176, 100])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"), 2, 134])
    end
    # Draw all images
    pbDrawImagePositions(overlay, imagepos)
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("MOVES"),
                _INTL("RIBBONS")][page - 1]
    textpos = [
      [pagename, 26, 22, 0, base, shadow],
      [@pokemon.name, 46, 68, 0, base, shadow],
      [@pokemon.level.to_s, 46, 98, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Item"), 66, 324, 0, base, shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name, 16, 358, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
    else
      textpos.push([_INTL("None"), 16, 358, 0, Color.new(192, 200, 208), Color.new(208, 216, 224)])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"), 178, 68, 0, Color.new(24, 112, 216), Color.new(136, 168, 208)])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"), 178, 68, 0, Color.new(248, 56, 32), Color.new(224, 152, 144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay, 84, 292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    end
  end
end

#===============================================================================
# Fixed some outdated code used in example map events.
#===============================================================================
module Compiler
  SCRIPT_REPLACEMENTS += [
    ["pbCheckAble",                  "$player.has_other_able_pokemon?"],
    ["$PokemonTemp.lastbattle",      "$game_temp.last_battle_record"],
    ["calcStats",                    "calc_stats"]
  ]
end

#===============================================================================
# Fixed incorrect Pokémon icons shown in Ready Menu if there are eggs in the
# party.
#===============================================================================
def pbUseKeyItem
  moves = [:CUT, :DEFOG, :DIG, :DIVE, :FLASH, :FLY, :HEADBUTT, :ROCKCLIMB,
           :ROCKSMASH, :SECRETPOWER, :STRENGTH, :SURF, :SWEETSCENT, :TELEPORT,
           :WATERFALL, :WHIRLPOOL]
  real_moves = []
  moves.each do |move|
    $player.party.each_with_index do |pkmn, i|
      next if pkmn.egg? || !pkmn.hasMove?(move)
      real_moves.push([move, i]) if pbCanUseHiddenMove?(pkmn, move, false)
    end
  end
  real_items = []
  $bag.registered_items.each do |i|
    itm = GameData::Item.get(i).id
    real_items.push(itm) if $bag.has?(itm)
  end
  if real_items.length == 0 && real_moves.length == 0
    pbMessage(_INTL("An item in the Bag can be registered to this key for instant use."))
  else
    $game_temp.in_menu = true
    $game_map.update
    sscene = PokemonReadyMenu_Scene.new
    sscreen = PokemonReadyMenu.new(sscene)
    sscreen.pbStartReadyMenu(real_moves, real_items)
    $game_temp.in_menu = false
  end
end

#===============================================================================
# Fixed not registering a gifted Pokémon as seen/owned before looking at its
# Pokédex entry.
#===============================================================================
def pbAddPokemon(pkmn, level = 1, see_form = true)
  return false if !pkmn
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $player.name, species_name))
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned && $player.has_pokedex
    pbMessage(_INTL("{1}'s data was added to the Pokédex.", species_name))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    }
  end
  # Nickname and add the Pokémon
  pbNicknameAndStore(pkmn)
  return true
end

def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return false if !pkmn || pbBoxesFull?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  pkmn.record_first_moves
  if $player.party_full?
    $PokemonStorage.pbStoreCaught(pkmn)
  else
    $player.party[$player.party.length] = pkmn
  end
  return true
end

def pbAddToParty(pkmn, level = 1, see_form = true)
  return false if !pkmn || $player.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $player.name, species_name))
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned && $player.has_pokedex
    pbMessage(_INTL("{1}'s data was added to the Pokédex.", species_name))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    }
  end
  # Nickname and add the Pokémon
  pbNicknameAndStore(pkmn)
  return true
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn || $player.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $player.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $player.name))
  end
  was_owned = $player.owned?(pkmn.species)
  $player.pokedex.set_seen(pkmn.species)
  $player.pokedex.set_owned(pkmn.species)
  $player.pokedex.register(pkmn) if see_form
  # Show Pokédex entry for new species if it hasn't been owned before
  if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && see_form && !was_owned && $player.has_pokedex
    pbMessage(_INTL("The Pokémon's data was added to the Pokédex."))
    $player.pokedex.register_last_seen(pkmn)
    pbFadeOutIn {
      scene = PokemonPokedexInfo_Scene.new
      screen = PokemonPokedexInfoScreen.new(scene)
      screen.pbDexEntry(pkmn.species)
    }
  end
  # Add the Pokémon
  pbStorePokemon(pkmn)
  return true
end

#===============================================================================
# Fixed the player animating super-fast for a while after surfing.
#===============================================================================
class Game_Player < Game_Character
  alias __hotfixes_update_pattern update_pattern
  def update_pattern
    __hotfixes_update_pattern
    @anime_count = 0 if $PokemonGlobal&.surfing || $PokemonGlobal&.diving
  end
end

#===============================================================================
# Fixed Howl always failing.
#===============================================================================
class Battle::Move::RaiseTargetAttack1 < Battle::Move
  def pbMoveFailed?(user, targets)
    return false if damagingMove?
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK, user, self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Fixed error when using Rotom Catalog.
#===============================================================================
ItemHandlers::UseOnPokemon.add(:ROTOMCATALOG, proc { |item, qty, pkmn, scene|
  if !pkmn.isSpecies?(:ROTOM)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  elsif pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  choices = [
    _INTL("Light bulb"),
    _INTL("Microwave oven"),
    _INTL("Washing machine"),
    _INTL("Refrigerator"),
    _INTL("Electric fan"),
    _INTL("Lawn mower"),
    _INTL("Cancel")
  ]
  new_form = scene.pbShowCommands(_INTL("Which appliance would you like to order?"),
     choices, pkmn.form)
  if new_form == pkmn.form
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif new_form > 0 && new_form < choices.length - 1
    pkmn.setForm(new_form) {
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} transformed!", pkmn.name))
    }
    next true
  end
  next false
})

#===============================================================================
# Fixed error when the Compiler tries to convert some pbTrainerBattle code to
# TrainerBattle.start.
#===============================================================================
module Compiler
  module_function

  def split_string_with_quotes(str)
    ret = []
    new_str = ""
    in_msg = false
    str.scan(/./) do |s|
      if s == "," && !in_msg
        ret.push(new_str.strip)
        new_str = ""
      else
        in_msg = !in_msg if s == "\""
        new_str += s
      end
    end
    new_str.strip!
    ret.push(new_str) if !new_str.empty?
    return ret
  end

  def replace_old_battle_scripts(event, list, index)
    changed = false
    script = list[index].parameters[1]
    if script[/^\s*pbWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      list[index].parameters[1] = sprintf("WildBattle.start(#{battle_params[0]}, #{battle_params[1]})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[3][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[4][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[2] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[2]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbDoubleWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      pkmn1 = "#{battle_params[0]}, #{battle_params[1]}"
      pkmn2 = "#{battle_params[2]}, #{battle_params[3]}"
      list[index].parameters[1] = sprintf("WildBattle.start(#{pkmn1}, #{pkmn2})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[5][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[6][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[4] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[4]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTripleWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      pkmn1 = "#{battle_params[0]}, #{battle_params[1]}"
      pkmn2 = "#{battle_params[2]}, #{battle_params[3]}"
      pkmn3 = "#{battle_params[4]}, #{battle_params[5]}"
      list[index].parameters[1] = sprintf("WildBattle.start(#{pkmn1}, #{pkmn2}, #{pkmn3})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[7][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[8][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[6] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[6]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTrainerBattle\((.+)\)\s*$/]
      echoln ""
      echoln $1
      battle_params = split_string_with_quotes($1)   # Split on commas
      echoln battle_params
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[4]}" if battle_params[4] && battle_params[4] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[2] && !battle_params[2].empty? && battle_params[2] != "nil"
        echoln battle_params[2]
        speech = battle_params[2].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        echoln speech
        push_comment(new_events, "EndSpeech: #{speech.strip}", old_indent)
      end
      if battle_params[3] && battle_params[3][/true/]
        push_script(new_events, "setBattleRule(\"double\")", old_indent)
      end
      if battle_params[5] && battle_params[5][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[6] && battle_params[6] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[6]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbDoubleTrainerBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[2]}" if battle_params[2] && battle_params[2] != "nil"
      trainer2 = "#{battle_params[4]}, #{battle_params[5]}"
      trainer2 += ", #{battle_params[6]}" if battle_params[6] && battle_params[6] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1}, #{trainer2})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && !battle_params[3].empty? && battle_params[3] != "nil"
        speech = battle_params[3].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech1: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[7] != "nil"
        speech = battle_params[7].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech2: #{speech.strip}", old_indent)
      end
      if battle_params[8] && battle_params[8][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[9] && battle_params[9] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[9]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTripleTrainerBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[2]}" if battle_params[2] && battle_params[2] != "nil"
      trainer2 = "#{battle_params[4]}, #{battle_params[5]}"
      trainer2 += ", #{battle_params[6]}" if battle_params[6] && battle_params[6] != "nil"
      trainer3 = "#{battle_params[8]}, #{battle_params[9]}"
      trainer3 += ", #{battle_params[10]}" if battle_params[10] && battle_params[10] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1}, #{trainer2}, #{trainer3})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && !battle_params[3].empty? && battle_params[3] != "nil"
        speech = battle_params[3].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech1: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[7] != "nil"
        speech = battle_params[7].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech2: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[11] != "nil"
        speech = battle_params[11].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech3: #{speech.strip}", old_indent)
      end
      if battle_params[12] && battle_params[12][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[13] && battle_params[13] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[13]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    end
    return changed
  end
end
