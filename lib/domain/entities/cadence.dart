enum Cadence {
  daily,
  weekly,
  monthly,
  once;

  String get label => switch (this) {
        Cadence.daily => 'Daily',
        Cadence.weekly => 'Weekly',
        Cadence.monthly => 'Monthly',
        Cadence.once => 'One-off',
      };
}
