use Amnesia

defdatabase Database do
  deftable(
    LED,
    [:index, :x, :y],
    type: :ordered_set
  )
end
