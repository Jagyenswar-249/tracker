double rollup(Iterable<({int effort, int percent})> items) {
  var totalWeight = 0;
  var sumWeightedPercent = 0;
  for (final item in items) {
    final effort = item.effort <= 0 ? 1 : item.effort;
    totalWeight += effort;
    sumWeightedPercent += effort * item.percent;
  }
  return totalWeight == 0 ? 0.0 : (sumWeightedPercent / totalWeight);
}
