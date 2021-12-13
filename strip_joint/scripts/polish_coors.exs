require Amnesia
require Amnesia.Helper
require Exquisite
require Database.LED

defmodule Script do
  def d(p1, p2) do
    :math.sqrt(:math.pow(p1.x - p2.x, 2) + :math.pow(p1.y - p2.y, 2))
  end

  def dy(p1, p2) do
    :math.sqrt(:math.pow(p1.y - p2.y, 2))
  end

  def dx(p1, p2) do
    :math.sqrt(:math.pow(p1.x - p2.x, 2))
  end

  def analyze_distances(distances) do
    max = distances |> Enum.max
    min = distances |> Enum.min
    median = Enum.at(distances, trunc length(distances)/2)
    average = (distances |> Enum.sum) / length(distances)

    %{max: max, min: min, median: median, average: average}
  end

  def pairs_to_distance(pairs, dfun) do
    pairs |> Enum.map(fn
      ([p1 | [p2 | _]]) -> dfun.(p1, p2)
      (_single) -> nil
    end) |> Enum.filter(& !is_nil(&1))
  end

  def correct_range(set) do
    col = for i <- 36..87, do: Database.LED.read!({set, i})
    pairs = col |> Enum.chunk_every(2, 1)
    pairs |> pairs_to_distance(&Script.d/2) |> analyze_distances
  end


  # I wanna say, skip until you reach two points with an unusual distance, we call this index i, from i start counting until (current_index-i)*normal_distance < distance(i, current_index). estimate the position of all LEDs in this range, do the same process for the rest of the LEDs

  def find_problem(set_name) do
    %{max: max} = correct_range(set_name)
    leds = StripJoint.Models.LED.set(set_name)

    pairs = Enum.chunk_every(leds, 2, 1)
    fix_distances(max, pairs)
  end

  def fix_distances(avg_distance, [[p1 | [p2 | _]] | rest]) do
    cond do
      d(p1, p2) > avg_distance * 1.5 ->
        take_bad_range(avg_distance, p1, rest)
      true ->
        fix_distances(avg_distance, rest)
    end
  end

  def fix_distances(_avg, _) do
    []
  end

  def take_bad_range(avg_distance, start, [ [_ | [p | _]] | rest]) do
    cond  do
      # need to do better here
      d(start, p) < avg_distance * (elem(p.index, 1) - elem(start.index, 1)) * 1.5 ->
        [[start, p] | fix_distances(avg_distance, rest)]
      true ->
        take_bad_range(avg_distance, start, rest)
    end
  end

  def take_bad_range(avg_distance, start, [last | _]) do
    [[start | last]]
  end

  def fix_and_save_to(set, new_set) do
    StripJoint.Models.LED.duplicate_set(set, new_set)
    find_problem(set)
    |> Enum.each(fn [a | [b | _]] ->
      ai = elem(a.index, 1)
      bi = elem(b.index, 1)
      IO.puts "from #{ai} to #{bi}"

      {dx, dy} = average_distance(a, b)


      LED.set(ai, "#FFFF0000")
      for i <- ((ai + 1)..(bi-1)) do
        StripJoint.Models.LED.update(i, a.x + (i - ai) * dx, a.y + (i - ai) * dy, new_set)
        LED.set(i, "#FF0000FF")
      end
      LED.set(bi, "#FFFF0000")
    end)
  end

  def show_problems(set_name) do
    find_problem(set_name)
    |> Enum.each(fn [a | [b | _]] ->
      ai = elem(a.index, 1)
      bi = elem(b.index, 1)

      LED.set(ai, "#FFFF0000")
      for i <- ((ai + 1)..(bi-1)) do
        LED.set(i, "#FF0000FF")
      end
      LED.set(bi, "#FFFF0000")
    end)
  end

  defp average_distance(a, b) do
    di = elem(b.index, 1) - elem(a.index, 1)
    {(b.x - a.x)/di, (b.y - a.y)/di}
  end
end


LED.off

Script.fix_and_save_to(:high_camera, :high_camera_polished)
#Script.show_problems(:high_camera)

# LED.set(90, "#FF0000FF")
# LED.set(91, "#FF0000FF")
# LED.set(92, "#FF0000FF")
# LED.set(93, "#FF0000FF")
# LED.set(94, "#FF0000FF")

LED.render
