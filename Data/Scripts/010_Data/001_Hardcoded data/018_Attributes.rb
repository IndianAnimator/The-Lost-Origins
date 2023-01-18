module GameData
  class Attribute
    attr_reader :id
    attr_reader :real_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id           = hash[:id]
      @real_name    = hash[:name]         || "Unnamed"
    end

    # @return [String] the translated name of this Attribute
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::Attribute.register({
  :id           => :MATYR,
  :name         => _INTL("Matyr")
})

GameData::Attribute.register({
  :id           => :DEVASTATION,
  :name         => _INTL("Devastation")
})

GameData::Attribute.register({
  :id           => :HERO,
  :name         => _INTL("Hero")
})

GameData::Attribute.register({
  :id           => :ROYALGUARD,
  :name         => _INTL("Royal Guard")
})

GameData::Attribute.register({
  :id           => :MONK,
  :name         => _INTL("Monk")
})


GameData::Attribute.register({
  :id           => :WARMONGER,
  :name         => _INTL("Warmonger")
})

GameData::Attribute.register({
  :id           => :KING,
  :name         => _INTL("King")
})

GameData::Attribute.register({
  :id           => :PRIES,
  :name         => _INTL("Priest")
})

GameData::Attribute.register({
  :id           => :PHOENIX,
  :name         => _INTL("Phoenix")
})

GameData::Attribute.register({
  :id           => :DEMIGOD,
  :name         => _INTL("Demigod")
})

GameData::Attribute.register({
  :id           => :FORGOTTEN,
  :name         => _INTL("Forgotten")
})


GameData::Attribute.register({
  :id           => :CORRUPTED,
  :name         => _INTL("Corrupted")
})

GameData::Attribute.register({
  :id           => :HOLYMAGE,
  :name         => _INTL("Holy Mage")
})

GameData::Attribute.register({
  :id           => :DELUSIONAL,
  :name         => _INTL("Delusional")
})

GameData::Attribute.register({
  :id           => :REINCARNATED,
  :name         => _INTL("Reincarnated")
})

GameData::Attribute.register({
  :id           => :DAMNED,
  :name         => _INTL("Damned")
})

GameData::Attribute.register({
  :id           => :PRIDE,
  :name         => _INTL("Pride")
})
