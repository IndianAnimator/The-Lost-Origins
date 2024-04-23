module GameData
    class Attribute
      attr_reader :id
      attr_reader :real_name
      attr_reader :stat_changes
      attr_reader :description
      attr_reader :effect

      DATA = {}

      extend ClassMethodsSymbols
      include InstanceMethods

      def self.load; end
      def self.save; end

      def initialize(hash)
        @id           = hash[:id]
        @real_name    = hash[:name]         || "Unnamed"
        @stat_changes = hash[:stat_changes] || []
        @description  = hash[:description]  || ""
        @effect       = hash[:effect]
      end

      # @return [String] translated name of this Attribute
      def name
        return _INTL(@real_name)
      end

      # @return [String] translated description of this Attribute
      def description
        return _INTL(@description)
      end
    end
  end

  #===============================================================================

  GameData::Attribute.register({
    :id           => :MATYR, # mispelled
    :name         => _INTL("Martyr"),
    :description  => _INTL("Self-destructing moves are boosted by 1.3x, 10% to not self-destruct")
  })

  GameData::Attribute.register({
    :id           => :DEVASTATION,
    :name         => _INTL("Devastator"),
    :description  => _INTL("All pokemon on field take 1.2x more damage")
  })

  GameData::Attribute.register({
    :id           => :HERO,
    :name         => _INTL("Hero"),
    :description  => _INTL("All moves gain a 1.1x boost upon defeating an enemy")
  })

  GameData::Attribute.register({
    :id           => :ROYALGUARD,
    :name         => _INTL("Royal Guard"),
    :description  => _INTL("All allied pokemon take 1.3x less damage")
  })

  GameData::Attribute.register({
    :id           => :MONK,
    :name         => _INTL("Monk"),
    :description  => _INTL("Serene Grace effect, Meditate increases spatk")
  })


  GameData::Attribute.register({
    :id           => :WARMONGER,
    :name         => _INTL("Warmonger"),
    :description  => _INTL("Moxie effect, all blade moves are boosted")
  })

  GameData::Attribute.register({
    :id           => :KING,
    :name         => _INTL("King"),
    :description  => _INTL("All allied pokemons accuracy are boosted by 10%, crit by 10%")
  })

  GameData::Attribute.register({
    :id           => :PRIEST,
    :name         => _INTL("Priest"),
    :description  => _INTL("Leftovers effect for party while active")
  })

  GameData::Attribute.register({
    :id           => :PHOENIX,
    :name         => _INTL("Phoenix"),
    :description  => _INTL("User will regain 25% hp after fainting, using healing, items and protect/substitute will have no effect")
  })

  GameData::Attribute.register({
    :id           => :DEMIGOD,
    :name         => _INTL("Demigod"),
    :description  => _INTL("All moves will have infinite PP and two turn moves will be one turn, using healing, items and and status moves will fail.")
  })

  GameData::Attribute.register({
    :id           => :FORGOTTEN,
    :name         => _INTL("Forgotten"),
    :description  => _INTL("1.25x evasion, applies magic coat for 1 turns")
  })

  GameData::Attribute.register({
    :id           => :CORRUPTED,
    :name         => _INTL("Corrupted"),
    :description  => _INTL("1.5x move boost, gains ghost type, applies curse effect to itself")
  })

  GameData::Attribute.register({
    :id           => :HOLYMAGE,
    :name         => _INTL("Holy Mage"),
    :stat_changes => [[:SPECIAL_ATTACK, 20]],
    :description  => _INTL("1.2x special attack, 1.2 boost to psychic and fairy moves")
  })

  GameData::Attribute.register({
    :id           => :DELUSIONAL,
    :name         => _INTL("Delusional"),
    :description  => _INTL("user is always confused and all opponents take damage from its rambling while it's on field. Sound-based moves have a chance to confuse opponent.")
  })

  GameData::Attribute.register({
    :id           => :REINCARNATED,
    :name         => _INTL("Reincarnated"),
    :description  => _INTL("Gain 1/8 hp after death, both attacking stat is boosted OR if user will tranform into an alternate form if it exists")
  })

  GameData::Attribute.register({
    :id           => :DAMNED,
    :name         => _INTL("Damned"),
    :description  => _INTL("All statuses effects are doubled. Defeatist effect, Mummy Effect")
  })

  GameData::Attribute.register({
    :id           => :PROUD,
    :name         => _INTL("Proud"),
    :description  => _INTL("Boosts highest stat by 1.2, Klutz effect")
  })

  GameData::Attribute.register({
    :id           => :SPY,
    :name         => _INTL("Spy"),
    :description  => _INTL("Boosts hiding moves, Infiltrator effect")
  })

  GameData::Attribute.register({
    :id           => :BERSERKER,
    :name         => _INTL("Berserker"),
    :description  => _INTL("Boosts attack by one stage, has a chance to disobey or use another move")
  })

  GameData::Attribute.register({
    :id           => :SOULKEEPER,
    :name         => _INTL("Soulkeeper"),
    :description  => _INTL("Wish effect upon fainting or restores 1/2 of ally's health")
  })

  GameData::Attribute.register({
    :id           => :REAPER,
    :name         => _INTL("Reaper"),
    :description  => _INTL("Heals 20% hp after fainting an opponent")
  })

  GameData::Attribute.register({
    :id           => :BEASTMASTER,
    :name         => _INTL("Beastmaster"),
    :description  => _INTL("Boosts highest stat  by one stage when using a Pokemon with a fully-evolved form, or boost both defenses by one stage if NFE")
  })

  GameData::Attribute.register({
    :id           => :ENTREPRENEUR,
    :name         => _INTL("Entrepreneur"),
    :description  => _INTL("Normal moves turn into one of user's type, boosted by 30% ")
  })

  GameData::Attribute.register({
    :id           => :PROPHET,
    :name         => _INTL("Prophet"),
    :description  => _INTL("Predicts a Super-Effective attack on opponent, Anticipation Effect")
  })
