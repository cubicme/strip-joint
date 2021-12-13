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

  def set(set_name) do
    Amnesia.transaction do
      Amnesia.Selection.values(LED.where elem(index, 0) == set_name)
    end
  end

  def duplicate_set(from, to) do
    Amnesia.transaction do
      set(from)
      |> Enum.each fn (%{index: {^from, index}} = led) -> update(index, led.x, led.y, to) end
    end
  end

  def update(index, x, y, set_name \\ :default) do
    Amnesia.transaction do
      LED.write(%LED{index: {set_name, index}, x: x, y: y})
    end
  end

  def get(index, set_name \\ :default) do
    LED.read({set_name, index})
  end

  def delete(index, set_name \\ :default) do
    LED.delete!({set_name, index})
  end

  def transform_old do
    all
    |> Enum.each fn ({Database.LED, index, x, y}) ->
     LED.delete!(index)
     delete(index)
     update(index, x, y)
    end
  end
end
