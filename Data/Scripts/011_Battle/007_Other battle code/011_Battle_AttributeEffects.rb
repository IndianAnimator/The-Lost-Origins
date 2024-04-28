#===============================================================================
#
#===============================================================================
module Battle::AttributeEffects
  SpeedCalc                        = AttributeHandlerHash.new
  WeightCalc                       = AttributeHandlerHash.new
  # Battler's HP/stat changed
  OnHPDroppedBelowHalf             = AttributeHandlerHash.new
  # Battler's status problem
  StatusCheckNonIgnorable          = AttributeHandlerHash.new   # Comatose
  StatusImmunity                   = AttributeHandlerHash.new
  StatusImmunityNonIgnorable       = AttributeHandlerHash.new
  StatusImmunityFromAlly           = AttributeHandlerHash.new
  OnStatusInflicted                = AttributeHandlerHash.new   # Synchronize
  StatusCure                       = AttributeHandlerHash.new
  # Battler's stat stages
  StatLossImmunity                 = AttributeHandlerHash.new
  StatLossImmunityNonIgnorable     = AttributeHandlerHash.new   # Full Metal Body
  StatLossImmunityFromAlly         = AttributeHandlerHash.new   # Flower Veil
  OnStatGain                       = AttributeHandlerHash.new   # None!
  OnStatLoss                       = AttributeHandlerHash.new
  # Priority and turn order
  PriorityChange                   = AttributeHandlerHash.new
  PriorityBracketChange            = AttributeHandlerHash.new   # Stall
  PriorityBracketUse               = AttributeHandlerHash.new   # None!
  # Move usage failures
  OnFlinch                         = AttributeHandlerHash.new   # Steadfast
  MoveBlocking                     = AttributeHandlerHash.new
  MoveImmunity                     = AttributeHandlerHash.new
  # Move usage
  ModifyMoveBaseType               = AttributeHandlerHash.new
  # Accuracy calculation
  AccuracyCalcFromUser             = AttributeHandlerHash.new
  AccuracyCalcFromAlly             = AttributeHandlerHash.new   # Victory Star
  AccuracyCalcFromTarget           = AttributeHandlerHash.new
  # Damage calculation
  DamageCalcFromUser               = AttributeHandlerHash.new
  DamageCalcFromAlly               = AttributeHandlerHash.new
  DamageCalcFromTarget             = AttributeHandlerHash.new
  DamageCalcFromTargetNonIgnorable = AttributeHandlerHash.new
  DamageCalcFromTargetAlly         = AttributeHandlerHash.new
  CriticalCalcFromUser             = AttributeHandlerHash.new
  CriticalCalcFromTarget           = AttributeHandlerHash.new
  # Upon a move hitting a target
  OnBeingHit                       = AttributeHandlerHash.new
  OnDealingHit                     = AttributeHandlerHash.new   # Poison Touch
  # Abilities that trigger at the end of using a move
  OnEndOfUsingMove                 = AttributeHandlerHash.new
  AfterMoveUseFromTarget           = AttributeHandlerHash.new
  # End Of Round
  EndOfRoundWeather                = AttributeHandlerHash.new
  EndOfRoundHealing                = AttributeHandlerHash.new
  EndOfRoundEffect                 = AttributeHandlerHash.new
  EndOfRoundGainItem               = AttributeHandlerHash.new
  # Switching and fainting
  CertainSwitching                 = AttributeHandlerHash.new   # None!
  TrappingByTarget                 = AttributeHandlerHash.new
  OnSwitchIn                       = AttributeHandlerHash.new
  OnSwitchOut                      = AttributeHandlerHash.new
  ChangeOnBattlerFainting          = AttributeHandlerHash.new
  OnBattlerFainting                = AttributeHandlerHash.new   # Soul-Heart
  OnTerrainChange                  = AttributeHandlerHash.new   # Mimicry
  OnIntimidated                    = AttributeHandlerHash.new   # Rattled (Gen 8)
  # Running from battle
  CertainEscapeFromBattle          = AttributeHandlerHash.new   # Run Away
  # Custom methods
  BeforeBeingHit                   = AttributeHandlerHash.new   # Forgotten (attribute)
  OnFaint                          = AttributeHandlerHash.new   # Phoenix/Reincarnated

  #=============================================================================

  def self.trigger(hash, *args, ret: false)
    new_ret = hash.trigger(*args)
    return (!new_ret.nil?) ? new_ret : ret
  end

  #=============================================================================

  def self.triggerSpeedCalc(attribute, battler, mult)
    return trigger(SpeedCalc, attribute, battler, mult, ret: mult)
  end

  def self.triggerWeightCalc(attribute, battler, weight)
    return trigger(WeightCalc, attribute, battler, weight, ret: weight)
  end

  #=============================================================================

  def self.triggerOnHPDroppedBelowHalf(attribute, user, move_user, battle)
    return trigger(OnHPDroppedBelowHalf, attribute, user, move_user, battle)
  end

  #=============================================================================

  def self.triggerStatusCheckNonIgnorable(attribute, battler, status)
    return trigger(StatusCheckNonIgnorable, attribute, battler, status)
  end

  def self.triggerStatusImmunity(attribute, battler, status)
    return trigger(StatusImmunity, attribute, battler, status)
  end

  def self.triggerStatusImmunityNonIgnorable(attribute, battler, status)
    return trigger(StatusImmunityNonIgnorable, attribute, battler, status)
  end

  def self.triggerStatusImmunityFromAlly(attribute, battler, status)
    return trigger(StatusImmunityFromAlly, attribute, battler, status)
  end

  def self.triggerOnStatusInflicted(attribute, battler, user, status)
    OnStatusInflicted.trigger(attribute, battler, user, status)
  end

  def self.triggerStatusCure(attribute, battler)
    return trigger(StatusCure, attribute, battler)
  end

  #=============================================================================

  def self.triggerStatLossImmunity(attribute, battler, stat, battle, show_messages)
    return trigger(StatLossImmunity, attribute, battler, stat, battle, show_messages)
  end

  def self.triggerStatLossImmunityNonIgnorable(attribute, battler, stat, battle, show_messages)
    return trigger(StatLossImmunityNonIgnorable, attribute, battler, stat, battle, show_messages)
  end

  def self.triggerStatLossImmunityFromAlly(attribute, bearer, battler, stat, battle, show_messages)
    return trigger(StatLossImmunityFromAlly, attribute, bearer, battler, stat, battle, show_messages)
  end

  def self.triggerOnStatGain(attribute, battler, stat, user)
    OnStatGain.trigger(attribute, battler, stat, user)
  end

  def self.triggerOnStatLoss(attribute, battler, stat, user)
    OnStatLoss.trigger(attribute, battler, stat, user)
  end

  #=============================================================================

  def self.triggerPriorityChange(attribute, battler, move, priority)
    return trigger(PriorityChange, attribute, battler, move, priority, ret: priority)
  end

  def self.triggerPriorityBracketChange(attribute, battler, battle)
    return trigger(PriorityBracketChange, attribute, battler, battle, ret: 0)
  end

  def self.triggerPriorityBracketUse(attribute, battler, battle)
    PriorityBracketUse.trigger(attribute, battler, battle)
  end

  #=============================================================================

  def self.triggerOnFlinch(attribute, battler, battle)
    OnFlinch.trigger(attribute, battler, battle)
  end

  def self.triggerMoveBlocking(attribute, bearer, user, targets, move, battle)
    return trigger(MoveBlocking, attribute, bearer, user, targets, move, battle)
  end

  def self.triggerMoveImmunity(attribute, user, target, move, type, battle, show_message)
    return trigger(MoveImmunity, attribute, user, target, move, type, battle, show_message)
  end

  #=============================================================================

  def self.triggerModifyMoveBaseType(attribute, user, move, type)
    return trigger(ModifyMoveBaseType, attribute, user, move, type, ret: type)
  end

  #=============================================================================

  def self.triggerAccuracyCalcFromUser(attribute, mods, user, target, move, type)
    AccuracyCalcFromUser.trigger(attribute, mods, user, target, move, type)
  end

  def self.triggerAccuracyCalcFromAlly(attribute, mods, user, target, move, type)
    AccuracyCalcFromAlly.trigger(attribute, mods, user, target, move, type)
  end

  def self.triggerAccuracyCalcFromTarget(attribute, mods, user, target, move, type)
    AccuracyCalcFromTarget.trigger(attribute, mods, user, target, move, type)
  end

  #=============================================================================

  def self.triggerDamageCalcFromUser(attribute, user, target, move, mults, base_damage, type)
    DamageCalcFromUser.trigger(attribute, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromAlly(attribute, user, target, move, mults, base_damage, type)
    DamageCalcFromAlly.trigger(attribute, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromTarget(attribute, user, target, move, mults, base_damage, type)
    DamageCalcFromTarget.trigger(attribute, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromTargetNonIgnorable(attribute, user, target, move, mults, base_damage, type)
    DamageCalcFromTargetNonIgnorable.trigger(attribute, user, target, move, mults, base_damage, type)
  end

  def self.triggerDamageCalcFromTargetAlly(attribute, user, target, move, mults, base_damage, type)
    DamageCalcFromTargetAlly.trigger(attribute, user, target, move, mults, base_damage, type)
  end

  def self.triggerCriticalCalcFromUser(attribute, user, target, crit_stage)
    return trigger(CriticalCalcFromUser, attribute, user, target, crit_stage, ret: crit_stage)
  end

  def self.triggerCriticalCalcFromTarget(attribute, user, target, crit_stage)
    return trigger(CriticalCalcFromTarget, attribute, user, target, crit_stage, ret: crit_stage)
  end

  #=============================================================================

  def self.triggerOnBeingHit(attribute, user, target, move, battle)
    OnBeingHit.trigger(attribute, user, target, move, battle)
  end

  def self.triggerOnDealingHit(attribute, user, target, move, battle)
    OnDealingHit.trigger(attribute, user, target, move, battle)
  end

  #=============================================================================

  def self.triggerOnEndOfUsingMove(attribute, user, targets, move, battle)
    OnEndOfUsingMove.trigger(attribute, user, targets, move, battle)
  end

  def self.triggerAfterMoveUseFromTarget(attribute, target, user, move, switched_battlers, battle)
    AfterMoveUseFromTarget.trigger(attribute, target, user, move, switched_battlers, battle)
  end

  #=============================================================================

  def self.triggerEndOfRoundWeather(attribute, weather, battler, battle)
    EndOfRoundWeather.trigger(attribute, weather, battler, battle)
  end

  def self.triggerEndOfRoundHealing(attribute, battler, battle)
    EndOfRoundHealing.trigger(attribute, battler, battle)
  end

  def self.triggerEndOfRoundEffect(attribute, battler, battle)
    EndOfRoundEffect.trigger(attribute, battler, battle)
  end

  def self.triggerEndOfRoundGainItem(attribute, battler, battle)
    EndOfRoundGainItem.trigger(attribute, battler, battle)
  end

  #=============================================================================

  def self.triggerCertainSwitching(attribute, switcher, battle)
    return trigger(CertainSwitching, attribute, switcher, battle)
  end

  def self.triggerTrappingByTarget(attribute, switcher, bearer, battle)
    return trigger(TrappingByTarget, attribute, switcher, bearer, battle)
  end

  def self.triggerOnSwitchIn(attribute, battler, battle, switch_in = false)
    OnSwitchIn.trigger(attribute, battler, battle, switch_in)
  end

  def self.triggerOnSwitchOut(attribute, battler, end_of_battle)
    OnSwitchOut.trigger(attribute, battler, end_of_battle)
  end

  def self.triggerChangeOnBattlerFainting(attribute, battler, fainted, battle)
    ChangeOnBattlerFainting.trigger(attribute, battler, fainted, battle)
  end

  def self.triggerOnBattlerFainting(attribute, battler, fainted, battle)
    OnBattlerFainting.trigger(attribute, battler, fainted, battle)
  end

  def self.triggerOnTerrainChange(attribute, battler, battle, attribute_changed)
    OnTerrainChange.trigger(attribute, battler, battle, attribute_changed)
  end

  def self.triggerOnIntimidated(attribute, battler, battle)
    OnIntimidated.trigger(attribute, battler, battle)
  end

  #=============================================================================

  def self.triggerCertainEscapeFromBattle(attribute, battler)
    return trigger(CertainEscapeFromBattle, attribute, battler)
  end

  #=============================================================================

  def self.triggerBeforeBeingHit(attribute, user, target, move, battle)
    return trigger(BeforeBeingHit, attribute, user, target, move, battle)
  end

  def self.triggerOnFaint(attribute,user,battle)
    return trigger(OnFaint, attribute, user, battle)
  end
end

Battle::AttributeEffects::OnEndOfUsingMove.add(:HERO,
  proc { |attribute, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    targets.each { |b| user.effects[PBEffects::HeroCount] += 1 if b.damageState.fainted }
    next if user.effects[PBEffects::HeroCount] == 0
    battle.pbDisplay(_INTL("{1}'s heroism increased!", user.pbThis))
  }
)

Battle::AttributeEffects::DamageCalcFromUser.add(:HERO,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    dmgboost = user.effects[PBEffects::HeroCount] * 0.1
    mults[:power_multiplier] *= dmgboost
  }
)

Battle::AttributeEffects::DamageCalcFromTarget.add(:ROYALGUARD,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.7
  }
)

Battle::AttributeEffects::DamageCalcFromTargetAlly.add(:ROYALGUARD,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.7
  }
)


Battle::AttributeEffects::OnEndOfUsingMove.add(:WARMONGER,
  proc { |attribute, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStage(:ATTACK, numFainted, user)
  }
)

Battle::AttributeEffects::DamageCalcFromUser.add(:WARMONGER,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:power_multiplier] *= 1.5 if move.blademove?
  }
)

Battle::AttributeEffects::AccuracyCalcFromUser.add(:KING,
  proc { |attribute, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

Battle::AttributeEffects::AccuracyCalcFromAlly.add(:KING,
  proc { |attribute, mods, user, target, move, type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

Battle::AttributeEffects::EndOfRoundHealing.add(:PRIEST,
  proc { |attribute, battler, battle|
    next if !battler.canHeal?
    battler.pbRecoverHP(battler.totalhp / 8)
    battle.pbDisplay(_INTL("{1}'s {2} restored its hp!", battler.pbThis, battler.attribute.name))
    battler.allAllies.each do |b|
      next if !b.canHeal?
      b.pbRecoverHP(b.totalhp / 8)
      battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s' hp!", battler.pbThis, battler.attribute.name, b.pbthis(true)))
    end
  }
)

Battle::AttributeEffects::OnEndOfUsingMove.add(:DEMIGOD,
  proc { |attribute, user, targets, move, battle|
    user.effects[PBEffects::Taunt] = 999
    regularMove = nil
    user.eachMove do |m|
      next if m.id != user.lastRegularMoveUsed
      regularMove = m
      break
    end
    regularMove.pp = regularMove.total_pp
  }
)

Battle::AttributeEffects::AccuracyCalcFromTarget.add(:FORGOTTEN,
  proc { |attribute, mods, user, target, move, type|
    mods[:evasion_multiplier] *= 1.25
    target.effects[PBEffects::MagicCoat] = true
  }
)

Battle::AttributeEffects::BeforeBeingHit.add(:FORGOTTEN,
  proc { |attribute, user, target, move, battle|
    battle.pbDisplay(_INTL("{1} forgot who its target was!", target.pbThis))
    newTargArr = []
    battle.allBattlers.each do |b|
      next if b == user
      next if b.attribute == :FORGOTTEN
      newTargArr.push(b)
    end
    newTargIdx = battle.pbRandom(newTargArr.length)

    newTarg = newTargArr[newTargIdx]
    echoln("new targ: #{newTarg.name} possible targets: ")
    newTargArr.each { |b| echoln("  #{b.name}") }
    if newTarg && newTargArr.length > 0
      target.pbUseMove([:UseMove, -1, move, newTarg.index])
    else
      target.pbConfusionDamage(_INTL("{1} is confused on who to attack!", target.pbThis))
    end
  }
)

Battle::AttributeEffects::DamageCalcFromUser.add(:CORRUPTED,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:power_multiplier] *= 1.5
    user.effects[PBEffects::ExtraType] = :GHOST
    user.effects[PBEffects::Curse] = true
  }
)

Battle::AttributeEffects::OnDealingHit.add(:DELUSIONAL,
  proc { |attribute, user, target, move, battle|
    user.effects[PBEffects::Confusion] = 999
    next if !move.soundMove?
    next if battle.pbRandom(100) >= 15
    if target.pbCanConfuse?(user, false)
      battle.pbDisplay(_INTL("{1}'s {2} confused {3}!", user.pbThis,
        user.attributeName, target.pbThis(true)))
      target.pbConfuse
    end
  }
)

Battle::AttributeEffects::DamageCalcFromUser.add(:DAMNED,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:attack_multiplier] /= 2 if user.hp <= user.totalhp / 2
  }
)

Battle::AttributeEffects::OnBeingHit.add(:DAMNED,
  proc { |attribute, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.attribute == :DAMNED
    oldAtr = nil
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      oldAtr = user.attribute
      user.pokemon.attribute=(:DAMNED)
      user.pbUpdate
      battle.pbDisplay(_INTL("{1}'s Attribute became {2}!", user.pbThis, user.attribute.name))
    end
    user.pbOnLosingAttribute(oldAtr)
    user.pbTriggerAttributeOnGainingIt
  }
)


Battle::AttributeEffects::DamageCalcFromUser.add(:SPY,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:power_multiplier] *= 1.5 if (move.function_code == "TwoTurnAttackInvulnerableInSky" ||               # Fly
    move.function_code == "TwoTurnAttackInvulnerableUnderground" ||            # Dig
    move.function_code == "TwoTurnAttackInvulnerableUnderwater" ||             # Dive
    move.function_code == "TwoTurnAttackInvulnerableInSkyParalyzeTarget" ||    # Bounce
    move.function_code == "TwoTurnAttackInvulnerableRemoveProtections" ||      # Shadow Force/Phantom Force
    move.function_code == "TwoTurnAttackInvulnerableInSkyTargetCannotAct") &&     # Sky Drop
    move.damagingTurn
  }
)

Battle::AttributeEffects::OnSwitchIn.add(:BERSERKER,
  proc { |attribute, battler, battle, switch_in|
    battler.pbRaiseStatStage(:ATTACK, 1, battler)
  }
)

Battle::AttributeEffects::OnEndOfUsingMove.add(:REAPER,
  proc { |attribute, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each do |b|
      if b.damageState.fainted && user.canHeal?
        user.pbRecoverHP(user.totalhp / 5)
        battle.pbDisplay(_INTL("{1}'s {2} absorbed {3}'s energy!", user.pbThis, user.attribute.name, b.pbThis(true)))
      end
    end
  }
)

Battle::AttributeEffects::OnSwitchIn.add(:BEASTMASTER,
  proc { |attribute, battler, battle, switch_in|
    if battler.pokemon.species_data.get_evolutions(true).length > 0
      battler.pbRaiseStatStage(:DEFENSE, 1, battler)
      battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
    else
      battlerStats = battler.plainStats
      highestStatValue = 0
      battlerStats.each_value { |value| highestStatValue = value if highestStatValue < value }
      GameData::Stat.each_main_battle do |s|
        next if battlerStats[s.id] < highestStatValue
        battler.pbRaiseStatStage(s.id, 1, battler)
        break
      end
    end
  }
)

Battle::AttributeEffects::ModifyMoveBaseType.add(:ENTREPRENEUR,
  proc { |attribute, user, move, type|
    types = user.pbTypes(true)
    typeIdx = rand(user.types.length)
    moveType = types[typeIdx]
    next if type != :NORMAL || !GameData::Type.exists?(moveType)
    move.powerBoost = true
    next moveType
  }
)

Battle::AttributeEffects::DamageCalcFromUser.add(:ENTREPRENEUR,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:power_multiplier] *= 1.2 if move.powerBoost
  }
)

Battle::AttributeEffects::OnSwitchIn.add(:PROPHET,
proc { |attribute, battler, battle, switch_in|
  next if !battler.pbOwnedByPlayer?
  next if battle.futureSight
  effects = battle.positions[battler.pbDirectOpposing.index].effects
  effects[PBEffects::FutureSightCounter]        = 2
  effects[PBEffects::FutureSightMove]           = :PROPHECY
  effects[PBEffects::FutureSightUserIndex]      = battler.index
  effects[PBEffects::FutureSightUserPartyIndex] = battler.pokemonIndex
  battle.pbDisplay(_INTL("{1} is foretelling a prophecy!", battler.pbThis))

  # anticipation shit
  battlerTypes = battler.pbTypes(true)
  types = battlerTypes
  found = false
  battle.allOtherSideBattlers(battler.index).each do |b|
    b.eachMove do |m|
      next if m.statusMove?
      if types.length > 0
        moveType = m.type
        if Settings::MECHANICS_GENERATION >= 6 && m.function_code == "TypeDependsOnUserIVs"   # Hidden Power
          moveType = pbHiddenPower(b.pokemon)[0]
        end
        eff = Effectiveness.calculate(moveType, *types)
        next if Effectiveness.ineffective?(eff)
        next if !Effectiveness.super_effective?(eff) &&
                !["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function_code)
      elsif !["OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"].include?(m.function_code)
        next
      end
      found = true
      break
    end
    break if found
  end
  if found
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} foretells the use of a dangerous move!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  end
  }
)

Battle::AttributeEffects::OnFaint.add(:PHOENIX,
  proc { |attribute, battler, battle|
    next if battler.effects[PBEffects::Phoenix]
    battler.effects[PBEffects::Phoenix] = true
    battler.effects[PBEffects::Embargo] = 9999 # I dont ever think round count will go to 9999
    battler.effects[PBEffects::Substitute] = 0
    battler.pbRecoverHP(battler.totalhp / 4)
    battle.pbDisplay(_INTL("{1}'s {2} made it come back from the ashes!", pbThis, battler.attribute.name))
    battler.fainted = true
  }
)

Battle::AttributeEffects::OnFaint.add(:REINCARNATED,
  proc { |attribute, battler, battle|
    next if battler.effects[PBEffects::Phoenix]
    battler.effects[PBEffects::Phoenix] = true
    battler.effects[PBEffects::Embargo] = 9999 # I dont ever think round count will go to 9999
    battler.effects[PBEffects::Substitute] = 0
    battler.pbRecoverHP(battler.totalhp / 8)
    availableForms = []
    availableNames = []
    #there is more than one form, so we can change it
    GameData::Species.each do |sp|
      next if sp.species != battler.species
      availableForms.push(sp.form)
      availableNames.push(sp.form_name.to_s.empty? ? _INTL("alternate") : sp.form_name)
    end
    #there is more than one form, so we can change it
    #delete the current form from the list of forms we can change to
    availableForms.delete_at(battler.form)
    availableNames.delete_at(battler.form)
    if availableForms.length > 0
      #there is more than one form, so we can change it
      sel = rand(availableForms.length)
      #set the form
      battler.pokemon.form = availableForms[sel]
      battler.form = battler.pokemon.form
      battle.pbAnimation(:TRANSFORM,battler,nil)
      battler.pbUpdate(true)
      battle.scene.pbChangePokemon(battler,battler.pokemon)
      battle.pbDisplay(_INTL("{1} reincarnated into its {2} form!", battler.pbThis, availableNames[sel]))
    else
      battle.pbDisplay(_INTL("{1} reincarnated!", battler.pbThis))
      battler.pbRaiseStatStage(:ATTACK, 1, battler)
      battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler)
    end
    battler.fainted = true
  }
)

Battle::AttributeEffects::OnFaint.add(:SOULKEEPER,
  proc { |attribute, battler, battle|
    next if battler.effects[PBEffects::Wish]

    if battle.pbSideBattlerCount(battler.index) == 1
      battle.positions[battler.index].effects[PBEffects::Wish]       = 2
      battle.positions[battler.index].effects[PBEffects::WishAmount] = (battler.totalhp / 2.0).round
      battle.positions[battler.index].effects[PBEffects::WishMaker]  = battler.pokemonIndex
      battle.pbDisplay(_INTL("{1}'s {2} allows its soul to help its allies", battler.name, battler.attribute.name))
    end
  }
)

Battle::AttributeEffects::EndOfRoundHealing.add(:SOULKEEPER,
  proc { |attribute, battler, battle|
    next if battle.pbSideBattlerCount(battler.index) == 1
    battler.allAllies.each do |b|
      next if !b.canHeal?
      b.pbRecoverHP(b.totalhp / 2)
      battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s' hp!", battler.name, battler.attribute.name, b.pbThis))
    end
  }
)

Battle::AttributeEffects::OnBeingHit.add(:PRODIGY,
  proc { |attribute, battler, target, move, battle|
    next if target.effects[PBEffects::Prodigy]
    next if !Effectiveness.super_effective?(move.type)
    target.effects[PBEffects::ProdigyTurns] = 4
    target.effects[PBEffects::ProdigyType] = move.type
  }
)

Battle::AttributeEffects::OnDealingHit.add(:POISONTOUCH,
  proc { |ability, user, target, move, battle|
    next if !move.contactMove?
    next if battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(user)
    if target.pbCanPoison?(user)
      msg = nil
      if !Battle::Scene::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!", user.pbThis, user.attribute.name, target.pbThis(true))
      end
      target.pbPoison(user, msg)
      target.effects[PBEffects::Bioweapon] = 3
    end
    battle.pbHideAbilitySplash(user)
  }
)
