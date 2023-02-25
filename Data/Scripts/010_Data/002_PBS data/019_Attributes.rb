module GameData
  class Attribute
    attr_reader :id
    attr_reader :real_name
    attr_reader :stat_changes
    attr_reader :description

    DATA = {}
    DATA_FILENAME = "attributes.dat"

    extend ClassMethodsSymbols
    include InstanceMethods

    SCHEMA = {
      "Name"         => [:name,        "s"],
      "StatChanges"  => [:stat_changes, "I"],
      "Description"  => [:description, "q"]
    }

    def initialize(hash)
      @id           = hash[:id]
      @real_name    = hash[:name]         || "Unnamed"
      @stat_changes = hash[:stat_changes] || []
      @description  = hash[:description]  || ""
    end

    # @return [String] the translated name of this ability
    def name
      return pbGetMessageFromHash(MessageTypes::Attributes, @real_name)
    end

    # @return [String] the translated description of this ability
    def description
      return pbGetMessageFromHash(MessageTypes::AttributeDescs, @description)
    end

  end
end
