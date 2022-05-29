# ignore messages on assigning z
class RuboCop::Cop::Style::NumericLiterals
  def on_int(node)
    return if node.parent&.source&.match(/[^\w]z *= *[0-9]/)
    check node
  end
end
