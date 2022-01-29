module Input

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if $CanToggle && trigger?(Input::AUX1) && $PokemonGlobal #remap your Q button on the F1 screen to change your speedup switch
      $PokemonGlobal.GameSpeed += 1
      $PokemonGlobal.GameSpeed = 0 if $PokemonGlobal.GameSpeed >= SPEEDUP_STAGES.size
    end
  end
end

SPEEDUP_STAGES = [1,2,3]
# $PokemonGlobal.GameSpeed = 0
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    $frame += 1
    # $PokemonGlobal.GameSpeed = 0 if $PokemonGlobal && !$PokemonGlobal.GameSpeed
    return unless $frame % SPEEDUP_STAGES[($PokemonGlobal && $PokemonGlobal.GameSpeed) ? $PokemonGlobal.GameSpeed : 0] == 0
    fast_forward_update
    $frame = 0
  end
end
