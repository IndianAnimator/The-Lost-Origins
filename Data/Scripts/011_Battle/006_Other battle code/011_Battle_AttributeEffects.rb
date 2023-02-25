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
end
#===============================================================================

Battle::AttributeEffects::OnEndOfUsingMove.add(:HERO,
  proc { |attribute, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    targets.each { |b| user.effects[PBEffects::HeroCount] += 0.1 if b.damageState.fainted }
    battle.pbDisplay(_INTL("{1}'s {2} increased!", user.pbThis, user.attribute.name))
  }
)

Battle::AttributeEffects::DamageCalcFromUser.add(:HERO,
  proc { |attribute, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] *=  user.effects[PBEffects::HeroCount]
  }
)
