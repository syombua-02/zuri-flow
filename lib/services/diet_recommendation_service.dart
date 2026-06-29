 import '../models/diet_plan.dart';

class DietRecommendationService {
  DietPlan getDietPlan({
    required String goal,
    required String activity,
    required String weight,
    required String height,
    Map<String, dynamic>? latestProgress,
    String limitations = 'None',
    String workoutDays = '3 days/week',
    String workoutIntensity = 'Moderate',
  }) {
    final normalizedGoal = goal.trim().toLowerCase();
    final normalizedActivity = activity.trim().toLowerCase();
    final normalizedLimitations = limitations.trim();
    final normalizedIntensity = workoutIntensity.trim();

    final double? weightKg = double.tryParse(weight.trim());

    final String notes =
        (latestProgress?['notes'] ?? '').toString().trim().toLowerCase();

    final bool hasBloating = _hasBloatingNotes(notes);
    final bool lowEnergy = _hasLowEnergyNotes(notes);

    final String calorieTarget = _buildCalorieTarget(
      goal: normalizedGoal,
      activity: normalizedActivity,
      weightKg: weightKg,
      workoutDays: workoutDays,
      workoutIntensity: normalizedIntensity,
    );

    final String proteinTarget = _buildProteinTarget(
      goal: normalizedGoal,
      weightKg: weightKg,
      workoutIntensity: normalizedIntensity,
    );

    final String hydrationTarget = _buildHydrationTarget(
      weightKg: weightKg,
      activity: normalizedActivity,
      hasBloating: hasBloating,
    );

    if (normalizedGoal.contains('weight loss')) {
      return _buildWeightLossPlan(
        goal: goal,
        activity: normalizedActivity,
        weightKg: weightKg,
        calorieTarget: calorieTarget,
        proteinTarget: proteinTarget,
        hydrationTarget: hydrationTarget,
        hasBloating: hasBloating,
        lowEnergy: lowEnergy,
        limitations: normalizedLimitations,
        workoutIntensity: normalizedIntensity,
      );
    }

    if (normalizedGoal.contains('muscle gain')) {
      return _buildMuscleGainPlan(
        goal: goal,
        activity: normalizedActivity,
        weightKg: weightKg,
        calorieTarget: calorieTarget,
        proteinTarget: proteinTarget,
        hydrationTarget: hydrationTarget,
        hasBloating: hasBloating,
        lowEnergy: lowEnergy,
        limitations: normalizedLimitations,
        workoutIntensity: normalizedIntensity,
      );
    }

    if (normalizedGoal.contains('toning')) {
      return _buildToningPlan(
        goal: goal,
        activity: normalizedActivity,
        weightKg: weightKg,
        calorieTarget: calorieTarget,
        proteinTarget: proteinTarget,
        hydrationTarget: hydrationTarget,
        hasBloating: hasBloating,
        lowEnergy: lowEnergy,
        limitations: normalizedLimitations,
        workoutIntensity: normalizedIntensity,
      );
    }

    return _buildBalancedWellnessPlan(
      goal: goal,
      activity: normalizedActivity,
      weightKg: weightKg,
      calorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      hydrationTarget: hydrationTarget,
      hasBloating: hasBloating,
      lowEnergy: lowEnergy,
      limitations: normalizedLimitations,
      workoutIntensity: normalizedIntensity,
    );
  }

  // =========================================================
  // PLAN BUILDERS
  // =========================================================

  DietPlan _buildWeightLossPlan({
    required String goal,
    required String activity,
    required double? weightKg,
    required String calorieTarget,
    required String proteinTarget,
    required String hydrationTarget,
    required bool hasBloating,
    required bool lowEnergy,
    required String limitations,
    required String workoutIntensity,
  }) {
    final breakfastOptions = <String>[
      '2 boiled eggs + 1 medium sweet potato (about 180–220g) + sliced tomato/cucumber. Good higher-protein breakfast with a controlled carb portion.',
      'Plain oats made with 1/2 cup dry oats + 1 cup low-fat milk + cinnamon + 1 boiled egg on the side.',
      '3/4 cup plain Greek yogurt or mala + 1 small banana + 1 tablespoon groundnuts + 1 boiled egg.',
      '1 vegetable omelette made with 2 eggs, onion, tomato and spinach + 1 slice whole wheat bread + 1/4 avocado.',
    ];

    final lunchOptions = <String>[
      '120–150g grilled chicken breast + 1/2 cup cooked ugali + 1 to 1 1/2 cups sukuma wiki + kachumbari.',
      '1 to 1 1/4 cups ndengu stew + 1/2 cup cooked rice + 1 cup cabbage/spinach + 1/4 avocado.',
      '120g tilapia + 1 medium boiled sweet potato + 1 to 1 1/2 cups mixed vegetables.',
      '120g lean beef stew + 1/2 cup rice + 1 cup managu/terere/spinach.',
    ];

    final dinnerOptions = <String>[
      '2-egg veggie omelette + 1 small arrowroot portion (2 small arrowroots) + kachumbari.',
      '120g grilled fish or chicken + 1 cup sautéed vegetables + 1/4 avocado. Keep dinner lighter than lunch.',
      '1 cup beans or ndengu + 1 small sweet potato + 1 cup spinach or sukuma wiki.',
      '120g minced beef stir-fry with mixed vegetables + 1/3 to 1/2 cup ugali if you trained that day.',
    ];

    final snackOptions = <String>[
      '1 boiled egg + 1 fruit (apple/orange/small banana)',
      '3/4 cup mala or plain yogurt',
      '1 small handful groundnuts (about 2 tablespoons)',
      'Carrot/cucumber sticks + 2 tablespoons hummus if available',
      '1 small apple + 1 tablespoon peanut butter',
    ];

    final mealTips = <String>[
      'Build each main meal around protein first: eggs, chicken, fish, lean beef, mala, beans or ndengu.',
      'For weight loss, keep starch portions moderate instead of removing them completely: about 1/2 cup rice/ugali or 1 medium sweet potato per main meal.',
      'Try to include vegetables at both lunch and dinner to improve fullness and fibre intake.',
      'If hunger is high, increase vegetables and protein first before increasing ugali, rice, bread or chapati.',
      if (activity == 'active' || workoutIntensity == 'Challenging')
        'You\'re training at a high level — keep some carbs at dinner after workout days instead of cutting them completely, or fat loss will stall.',
      if (activity == 'beginner')
        'Start simple: focus on consistent meals over perfect macros. Three solid balanced meals beats complicated dieting.',
      if (lowEnergy)
        'Your recent notes suggest lower energy — do not under-eat. Keep breakfast solid and include a carb + protein combo before or after workouts.',
      if (limitations == 'Knee Pain' || limitations == 'Back Pain')
        'Support recovery with anti-inflammatory foods: fatty fish, leafy greens, turmeric in food, and consistent hydration.',
      if (limitations == 'Beginner Confidence')
        'Keep it simple: pick one meal per day to improve rather than overhauling everything at once.',
    ];

    final avoidOrLimit = <String>[
      'Large fries/chips portions and frequent takeout meals',
      'Sugary drinks, sweetened tea several times a day, and juice taken like water',
      'Very large late-night portions after skipping meals all day',
      'Stacking chapati + rice + fries in one sitting when fat loss is the goal',
    ];

    final hydrationTip = hasBloating
        ? 'Aim for steady water intake through the day rather than drinking huge amounts at once. Warm water, ginger tea, or peppermint tea can help if you feel bloated.'
        : 'Aim for steady hydration through the day. Start the morning with water and include water with each meal and snack.';

    return DietPlan(
      goal: goal,
      title: 'Weight Loss Meal Plan',
      calorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      hydrationTarget: hydrationTarget,
      hydrationTip: hydrationTip,
      summary: hasBloating
          ? 'This fat-loss plan keeps your meals protein-forward and portion-aware while also easing bloating with lighter digestion-friendly meal choices.'
          : 'This fat-loss plan keeps your meals high in protein, moderate in carbs, realistic for Kenyan eating habits, and easier to stay consistent with.',
      breakfastOptions: breakfastOptions,
      lunchOptions: lunchOptions,
      dinnerOptions: dinnerOptions,
      snackOptions: snackOptions,
      mealTips: mealTips,
      avoidOrLimit: avoidOrLimit,
      hasBloatingSupport: hasBloating,
      bloatingInsight: hasBloating
          ? 'Your latest progress notes suggest bloating or digestive discomfort. For the next 1–3 days, keep meals simpler, reduce excess salt and fizzy/sugary drinks, and choose cooked foods over very heavy greasy meals.'
          : '',
      bloatingFoodsToPrefer: hasBloating
          ? [
              'Warm water, ginger tea, peppermint tea, or lemon water if it feels comfortable',
              'Cooked oats, plain rice, sweet potato, arrowroots, or soft ugali in moderate portions',
              'Eggs, grilled fish, chicken, mala/yogurt if dairy sits well with you',
              'Cooked vegetables like spinach, zucchini, carrots, pumpkin or well-cooked sukuma in moderate amounts',
              'Banana, pawpaw, or small fruit portions that feel easy on your stomach',
            ]
          : [],
      bloatingFoodsToReduce: hasBloating
          ? [
              'Very salty fast foods, chips, and processed snacks',
              'Large bean portions if beans usually make you gassy',
              'Soft drinks, energy drinks, and too much sweetened juice',
              'Huge raw salad portions if your stomach already feels irritated',
              'Eating too fast, overeating at night, or going long hours without food then having a very heavy meal',
            ]
          : [],
      bloatingMealIdeas: hasBloating
          ? [
              'Anti-bloat breakfast: 1/2 cup oats cooked in water or milk + 1 boiled egg + 1/2 banana.',
              'Anti-bloat lunch: 120g grilled chicken + 1/2 cup plain rice + 1 cup cooked spinach/carrots.',
              'Anti-bloat dinner: 120g fish + 2 small arrowroots + 1 cup sautéed zucchini/spinach.',
            ]
          : [],
    );
  }

  DietPlan _buildMuscleGainPlan({
    required String goal,
    required String activity,
    required double? weightKg,
    required String calorieTarget,
    required String proteinTarget,
    required String hydrationTarget,
    required bool hasBloating,
    required bool lowEnergy,
    required String limitations,
    required String workoutIntensity,
  }) {
    final breakfastOptions = <String>[
      '3 eggs + 1 large sweet potato (250–300g) + 1 glass milk. Great for protein + training fuel.',
      'Oats made with 3/4 cup dry oats + 1 cup milk + 1 banana + 1 tablespoon peanut butter.',
      '2 slices whole wheat bread + 3-egg omelette + 1/2 avocado.',
      '1 cup mala/Greek yogurt + 1/2 cup oats + 1 banana + 2 tablespoons groundnuts.',
    ];

    final lunchOptions = <String>[
      '150–180g chicken stew + 1 to 1 1/2 cups cooked rice + 1 cup sukuma wiki.',
      '150g beef stew + 1 cup ugali + 1 cup spinach/managu.',
      '150g tilapia + 250g potatoes or matoke + 1 cup vegetables.',
      '1 1/2 cups beans/ndengu + 1 cup rice + 1/2 avocado + greens.',
    ];

    final dinnerOptions = <String>[
      '150g chicken breast + 250g sweet potato + 1 cup vegetables.',
      '150g minced beef + 1 cup rice + kachumbari + 1/4 avocado.',
      '3 eggs + 2 medium arrowroots + sautéed greens + 1 glass milk if needed to push calories.',
      '150g fish + 3/4 to 1 cup ugali + managu/terere.',
    ];

    final snackOptions = <String>[
      'Banana + 2 tablespoons peanut butter',
      '2 boiled eggs + 1 fruit',
      '1 cup mala or Greek yogurt',
      'Milk smoothie with milk + oats + banana + peanut butter',
      'Homemade sandwich with eggs/chicken/tuna',
    ];

    final mealTips = <String>[
      'For muscle gain, every main meal should contain both protein and a meaningful carb portion.',
      'Try not to “accidentally diet.” If your training is hard, a tiny lunch and then snacks all day will make progress slower.',
      'A post-workout meal should ideally include protein + carbs within a few hours, for example chicken and rice, eggs and sweet potato, or mala + oats + banana.',
      'If appetite is low, use calorie-dense extras like avocado, milk, peanut butter, eggs and smoothies.',
      if (activity == 'active' || workoutIntensity == 'Challenging')
        'With your training intensity, aim for protein within 30–60 minutes after workouts. Pre-workout: a small carb + protein snack 1–2 hrs before helps performance.',
      if (activity == 'beginner')
        'As a beginner, focus on hitting protein targets at each meal before worrying about timing. Consistency is more important than precision right now.',
      if (lowEnergy)
        'Your notes suggest lower energy — make sure you are not under-fueling. Add a proper carb source at lunch and dinner, not just protein alone.',
      if (limitations == 'Knee Pain' || limitations == 'Back Pain')
        'Prioritise anti-inflammatory foods to support joint recovery: salmon, sardines, leafy greens, berries, ginger and turmeric in cooking.',
    ];

    final avoidOrLimit = <String>[
      'Skipping meals and trying to “catch up” only at night',
      'Very low-carb eating while also expecting strength gains',
      'Doing intense training with only tea or one small snack in your system',
      'Relying only on protein shakes without solid meals',
    ];

    final hydrationTip = hasBloating
        ? 'Stay hydrated, but keep drinks spread out through the day. If bloated, choose water, ginger tea, or peppermint tea and avoid taking huge fizzy drinks with meals.'
        : 'Drink water steadily through the day, and increase fluids around workouts. Muscle gain still needs good hydration for recovery and performance.';

    return DietPlan(
      goal: goal,
      title: 'Muscle Gain Meal Plan',
      calorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      hydrationTarget: hydrationTarget,
      hydrationTip: hydrationTip,
      summary: hasBloating
          ? 'This muscle-gain plan still supports recovery and strength, but temporarily leans on easier-to-digest meals so you can eat enough without feeling overly heavy or bloated.'
          : 'This muscle-gain plan is built to support training, recovery and steady calorie intake with realistic protein-rich Kenyan meals.',
      breakfastOptions: breakfastOptions,
      lunchOptions: lunchOptions,
      dinnerOptions: dinnerOptions,
      snackOptions: snackOptions,
      mealTips: mealTips,
      avoidOrLimit: avoidOrLimit,
      hasBloatingSupport: hasBloating,
      bloatingInsight: hasBloating
          ? 'You still need enough calories for muscle gain, but for the next few days choose easier-to-digest carbs and proteins so you can keep eating without worsening bloating.'
          : '',
      bloatingFoodsToPrefer: hasBloating
          ? [
              'Rice, potatoes, arrowroots, sweet potato, oats',
              'Eggs, fish, chicken, mala/yogurt if tolerated',
              'Cooked vegetables instead of huge raw salads',
              'Smaller meals spread through the day instead of one giant heavy meal',
            ]
          : [],
      bloatingFoodsToReduce: hasBloating
          ? [
              'Very greasy takeout',
              'Huge bean portions right before training',
              'Too much soda, fizzy juice or sugary coffee drinks',
              'Very large cheat meals if your stomach already feels uncomfortable',
            ]
          : [],
      bloatingMealIdeas: hasBloating
          ? [
              'Anti-bloat breakfast: 3 eggs + 1 medium sweet potato + warm ginger tea.',
              'Anti-bloat lunch: 150g grilled fish/chicken + 1 cup rice + 1 cup cooked carrots/spinach.',
              'Anti-bloat snack: mala or Greek yogurt + banana if dairy sits well with you.',
            ]
          : [],
    );
  }

  DietPlan _buildToningPlan({
    required String goal,
    required String activity,
    required double? weightKg,
    required String calorieTarget,
    required String proteinTarget,
    required String hydrationTarget,
    required bool hasBloating,
    required bool lowEnergy,
    required String limitations,
    required String workoutIntensity,
  }) {
    final breakfastOptions = <String>[
      '2 eggs + 1 medium sweet potato + tomato/cucumber on the side.',
      '1/2 cup oats cooked in milk + 3/4 cup Greek yogurt or mala.',
      '2 slices whole wheat bread + 2 boiled eggs + 1/4 to 1/2 avocado.',
      '1 cup mala + 1 small banana + 1 tablespoon groundnuts + 1 boiled egg.',
    ];

    final lunchOptions = <String>[
      '120–150g chicken + 1/2 to 3/4 cup ugali + 1 to 1 1/2 cups sukuma wiki.',
      '1 to 1 1/4 cups ndengu + 1/2 cup rice + cabbage/spinach.',
      '120g fish + 1 medium sweet potato + 1 cup greens.',
      '120g lean beef + 1/2 cup rice + mixed vegetables.',
    ];

    final dinnerOptions = <String>[
      '2-egg omelette with onion/tomato/spinach + 2 small arrowroots + kachumbari.',
      '120g chicken or fish + 1 cup vegetables + 1/4 avocado.',
      '1 cup beans/ndengu + 1 small sweet potato + spinach.',
      '120g lean beef stir-fry + mixed vegetables + optional 1/3 cup rice if you trained that day.',
    ];

    final snackOptions = <String>[
      'Plain yogurt or mala (3/4 to 1 cup)',
      '1 boiled egg + fruit',
      '1 small handful groundnuts',
      'Banana smoothie made with milk if you need a more filling snack',
      'Apple + peanut butter',
    ];

    final mealTips = <String>[
      'For toning/body recomposition, keep protein consistent across breakfast, lunch, dinner and snacks.',
      'Use moderate starch portions instead of removing carbs completely. That helps with training, recovery and appetite control.',
      'A good plate structure is: 1 palm of protein + 1 fist of carbs + 1–2 fists of vegetables.',
      'If you feel flat or weak in workouts, add a little more carbs around training rather than cutting food harder.',
      if (activity == 'active' || workoutIntensity == 'Challenging')
        'Higher training intensity means your body needs enough fuel. Don\'t cut too aggressively on hard training days — keep carbs moderate at lunch and dinner.',
      if (activity == 'beginner')
        'Build the habit of eating protein at every meal before fine-tuning portions. A simple consistent routine beats a perfect but unsustainable one.',
      if (lowEnergy)
        'Your notes suggest lower energy — keep breakfast and lunch more structured instead of relying only on dinner to recover.',
      if (limitations == 'Knee Pain' || limitations == 'Back Pain')
        'Include anti-inflammatory foods regularly: leafy greens, fish, berries, ginger, and olive oil help with joint and muscle recovery.',
      if (limitations == 'Beginner Confidence')
        'Focus on one small win at a time — adding vegetables to lunch, or swapping one snack. Progress builds confidence.',
    ];

    final avoidOrLimit = <String>[
      'Frequent “healthy” undereating followed by overeating at night',
      'Too many fried snacks in place of real meals',
      'Very low protein intake while expecting body recomposition',
      'Skipping lunch and then eating the whole day’s calories late at night',
    ];

    final hydrationTip = hasBloating
        ? 'Hydration can help reduce the puffy/heavy feeling. Sip water steadily all day and try ginger or peppermint tea if your stomach feels uncomfortable.'
        : 'Hydration helps with digestion, recovery and that leaner “not puffy” feeling. Keep your water intake steady instead of cramming it all at once.';

    return DietPlan(
      goal: goal,
      title: 'Toning / Body Recomposition Meal Plan',
      calorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      hydrationTarget: hydrationTarget,
      hydrationTip: hydrationTip,
      summary: hasBloating
          ? 'This toning plan keeps portions controlled and protein high, while using lighter digestion-friendly meals to reduce bloating and help you feel less puffy.'
          : 'This toning plan supports a leaner, stronger look by keeping protein high, portions balanced, and meals realistic enough to follow consistently.',
      breakfastOptions: breakfastOptions,
      lunchOptions: lunchOptions,
      dinnerOptions: dinnerOptions,
      snackOptions: snackOptions,
      mealTips: mealTips,
      avoidOrLimit: avoidOrLimit,
      hasBloatingSupport: hasBloating,
      bloatingInsight: hasBloating
          ? 'Because your latest notes mention bloating or digestive discomfort, Zuri is temporarily prioritizing simpler meals, less excess salt, and gentler food combinations.'
          : '',
      bloatingFoodsToPrefer: hasBloating
          ? [
              'Eggs, fish, chicken, yogurt/mala if tolerated',
              'Rice, sweet potato, arrowroots, oats',
              'Cooked vegetables in moderate portions rather than huge raw salad bowls',
              'Warm fluids like ginger tea, peppermint tea, or warm water',
            ]
          : [],
      bloatingFoodsToReduce: hasBloating
          ? [
              'Heavy fried foods and fast foods',
              'Soft drinks and excess sugary drinks',
              'Very salty snacks that make you feel puffy',
              'Very large bean portions if they make you gassy',
            ]
          : [],
      bloatingMealIdeas: hasBloating
          ? [
              'Anti-bloat breakfast: 2 eggs + 1/2 cup oats + warm ginger tea.',
              'Anti-bloat lunch: 120g grilled chicken + 1/2 cup rice + cooked spinach/carrots.',
              'Anti-bloat dinner: 120g fish + 2 small arrowroots + 1 cup sautéed vegetables.',
            ]
          : [],
    );
  }

  DietPlan _buildBalancedWellnessPlan({
    required String goal,
    required String activity,
    required double? weightKg,
    required String calorieTarget,
    required String proteinTarget,
    required String hydrationTarget,
    required bool hasBloating,
    required bool lowEnergy,
    required String limitations,
    required String workoutIntensity,
  }) {
    final breakfastOptions = <String>[
      '2 eggs + 2 slices whole wheat bread + tomato/cucumber.',
      '1/2 cup oats cooked in milk + 1 banana.',
      '1 medium sweet potato + 1 cup mala or plain yogurt.',
      '2 boiled eggs + 1/4 avocado + 1 slice whole wheat bread.',
    ];

    final lunchOptions = <String>[
      '120g chicken + 1/2 to 3/4 cup rice + 1 cup vegetables.',
      '1 to 1 1/4 cups beans or ndengu + 1/2 cup ugali + sukuma wiki.',
      '120g fish + 1 medium sweet potato + greens.',
      '120g beef stew + 1/2 cup rice + mixed vegetables.',
    ];

    final dinnerOptions = <String>[
      '2 eggs + sautéed vegetables + 1 small arrowroot portion.',
      '120g chicken or fish + vegetables + 1/4 avocado.',
      '1 cup beans + spinach + 1 small sweet potato.',
      'Light beef stew + greens + optional 1/3 cup rice if hungry.',
    ];

    final snackOptions = <String>[
      'Fruit + yogurt',
      '1 boiled egg',
      'Groundnuts (small handful)',
      'Mala or Greek yogurt',
    ];

    final mealTips = <String>[
      'Aim for a simple balanced plate most of the time: protein + vegetables + a moderate starch portion.',
      'Try not to skip meals too often, especially if that leads to overeating later.',
      'Use snacks to support hunger and energy, not to replace every proper meal.',
      if (activity == 'active' || workoutIntensity == 'Challenging')
        'With regular active training, make sure your meals adequately fuel your workouts. Include carbs at lunch and around training sessions.',
      if (activity == 'beginner')
        'Keep it simple and consistent. Three balanced meals a day is a great starting point — master that before adding complexity.',
      if (lowEnergy)
        'Your notes suggest low energy — ensure breakfast and lunch contain both protein and carbs, not just tea and snacks.',
      if (limitations == 'Knee Pain' || limitations == 'Back Pain')
        'Focus on anti-inflammatory foods to support joint health: leafy greens, fish, berries, ginger and turmeric.',
      if (limitations == 'Bloating')
        'For bloating management, eat slowly, avoid very large meals, and favour cooked vegetables over large raw salads.',
      if (limitations == 'Beginner Confidence')
        'Start with one simple habit: ensure every meal has a protein source. That single change makes a big difference.',
    ];

    final avoidOrLimit = <String>[
      'Too many sugary drinks',
      'Frequent very large late-night meals',
      'Going long hours without eating then overeating',
    ];

    final hydrationTip = hasBloating
        ? 'Drink water steadily and use gentler fluids like ginger tea or warm water if your stomach feels bloated.'
        : 'Drink water consistently through the day and include fruit/vegetables regularly for digestion and recovery.';

    return DietPlan(
      goal: goal,
      title: 'Balanced Wellness Meal Plan',
      calorieTarget: calorieTarget,
      proteinTarget: proteinTarget,
      hydrationTarget: hydrationTarget,
      hydrationTip: hydrationTip,
      summary: hasBloating
          ? 'This balanced plan keeps meals nourishing and steady while using easier-to-digest choices to calm bloating.'
          : 'This balanced plan focuses on realistic, nourishing meals that support steady energy, digestion, and consistency.',
      breakfastOptions: breakfastOptions,
      lunchOptions: lunchOptions,
      dinnerOptions: dinnerOptions,
      snackOptions: snackOptions,
      mealTips: mealTips,
      avoidOrLimit: avoidOrLimit,
      hasBloatingSupport: hasBloating,
      bloatingInsight: hasBloating
          ? 'Your recent notes suggest bloating, so Zuri is nudging you toward lighter, less salty, easier-to-digest meals for the next few days.'
          : '',
      bloatingFoodsToPrefer: hasBloating
          ? [
              'Oats, rice, sweet potato, arrowroots',
              'Eggs, fish, chicken, yogurt if tolerated',
              'Cooked vegetables and warm fluids',
            ]
          : [],
      bloatingFoodsToReduce: hasBloating
          ? [
              'Greasy takeout',
              'Soft drinks',
              'Huge heavy meals',
            ]
          : [],
      bloatingMealIdeas: hasBloating
          ? [
              '1/2 cup oats + 1 boiled egg for breakfast',
              '120g chicken + 1/2 cup rice + cooked vegetables for lunch',
              'Fish + arrowroots + spinach for dinner',
            ]
          : [],
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  bool _hasBloatingNotes(String notes) {
    final lower = notes.toLowerCase();
    return lower.contains('bloated') ||
        lower.contains('bloating') ||
        lower.contains('gassy') ||
        lower.contains('gas') ||
        lower.contains('constipation') ||
        lower.contains('constipated') ||
        lower.contains('stomach');
  }

  bool _hasLowEnergyNotes(String notes) {
    final lower = notes.toLowerCase();
    return lower.contains('tired') ||
        lower.contains('low energy') ||
        lower.contains('fatigue') ||
        lower.contains('weak') ||
        lower.contains('drained');
  }

  String _buildCalorieTarget({
    required String goal,
    required String activity,
    required double? weightKg,
    required String workoutDays,
    required String workoutIntensity,
  }) {
    final weight = weightKg ?? 65;

    double base;
    if (goal.contains('weight loss')) {
      base = weight * 24 - 250;
    } else if (goal.contains('muscle gain')) {
      base = weight * 30 + 250;
    } else if (goal.contains('toning')) {
      base = weight * 26;
    } else {
      base = weight * 27;
    }

    // Fix: actual stored values are 'Active', 'Moderate', 'Beginner'
    if (activity == 'active') {
      base += 200;
    } else if (activity == 'moderate') {
      base += 100;
    }
    // 'beginner' gets no adjustment

    // More training days = more fuel needed
    if (workoutDays.contains('5') || workoutDays.contains('6')) {
      base += 150;
    } else if (workoutDays.contains('4')) {
      base += 75;
    }

    // Challenging intensity burns more
    if (workoutIntensity == 'Challenging') {
      base += 100;
    } else if (workoutIntensity == 'Gentle') {
      base -= 50;
    }

    final rounded = (base / 50).round() * 50;
    final lower = rounded - 100;
    final upper = rounded + 100;

    return 'Approx. $lower–$upper kcal/day';
  }

  String _buildProteinTarget({
    required String goal,
    required double? weightKg,
    required String workoutIntensity,
  }) {
    final weight = weightKg ?? 65;

    double multiplier;
    if (goal.contains('weight loss')) {
      multiplier = 1.6;
    } else if (goal.contains('muscle gain')) {
      multiplier = 1.8;
    } else if (goal.contains('toning')) {
      multiplier = 1.7;
    } else {
      multiplier = 1.4;
    }

    // Challenging workouts need more protein for repair
    if (workoutIntensity == 'Challenging') {
      multiplier += 0.2;
    } else if (workoutIntensity == 'Gentle') {
      multiplier -= 0.1;
    }

    final grams = (weight * multiplier).round();
    return 'Aim for about $grams g protein/day';
  }

  String _buildHydrationTarget({
    required double? weightKg,
    required String activity,
    required bool hasBloating,
  }) {
    final weight = weightKg ?? 65;
    double litres = weight * 0.033;

    // Fix: match actual stored values 'Active', 'Moderate', 'Beginner'
    if (activity == 'active') {
      litres += 0.7;
    } else if (activity == 'moderate') {
      litres += 0.4;
    }

    if (hasBloating) {
      litres += 0.2;
    }

    final rounded = litres.clamp(1.8, 4.0);
    return '${rounded.toStringAsFixed(1)} L/day';
  }
}