module Graphics
    @@speedup_frame = 0
  
    unless defined?(pre_ff_update)
      class << Graphics
        alias pre_ff_update update
      end
    end
  
    def self.update
      return if $PokemonSystem&.speedup&.>(@@speedup_frame += 1)
      pre_ff_update
      @@speedup_frame = 0
    end
  end
  