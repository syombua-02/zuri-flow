class DietPlan {
  final String goal;
  final String title;
  final String calorieTarget;
  final String proteinTarget;
  final String hydrationTip;
  final String hydrationTarget;
  final String summary;

  final List<String> breakfastOptions;
  final List<String> lunchOptions;
  final List<String> dinnerOptions;
  final List<String> snackOptions;
  final List<String> mealTips;
  final List<String> avoidOrLimit;

  // Extra personalization / symptom support
  final bool hasBloatingSupport;
  final String bloatingInsight;
  final List<String> bloatingFoodsToPrefer;
  final List<String> bloatingFoodsToReduce;
  final List<String> bloatingMealIdeas;

  const DietPlan({
    required this.goal,
    required this.title,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.hydrationTip,
    required this.hydrationTarget,
    required this.summary,
    required this.breakfastOptions,
    required this.lunchOptions,
    required this.dinnerOptions,
    required this.snackOptions,
    required this.mealTips,
    required this.avoidOrLimit,
    this.hasBloatingSupport = false,
    this.bloatingInsight = '',
    this.bloatingFoodsToPrefer = const [],
    this.bloatingFoodsToReduce = const [],
    this.bloatingMealIdeas = const [],
  });
}
