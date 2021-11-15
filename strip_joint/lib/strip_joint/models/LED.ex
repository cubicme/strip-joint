defmodule StripJoint.Models.LED do
  require Amnesia
  require Amnesia.Helper
  require Exquisite
  require Database.LED

  alias Database.LED

  def all do
    Amnesia.transaction do
      LED.foldl([], &([&1 | &2]))
    end
  end

  def update(index, x, y) do
    Amnesia.transaction do
      LED.write(%LED{index: index, x: x, y: y})
    end
  end
end
