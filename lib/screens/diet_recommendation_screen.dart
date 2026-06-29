import 'package:flutter/material.dart';
import '../models/diet_plan.dart';
import '../services/diet_recommendation_service.dart';
import '../services/firestore_service.dart';

class DietRecommendationScreen extends StatefulWidget {
  const DietRecommendationScreen({super.key});

  @override
  State<DietRecommendationScreen> createState() =>
      _DietRecommendationScreenState();
}

class _DietRecommendationScreenState extends State<DietRecommendationScreen> {
  final FirestoreService _firestore = FirestoreService();
  final DietRecommendationService _dietService = DietRecommendationService();

  Map<String, dynamic>? userData;
  Map<String, dynamic>? latestProgress;
  DietPlan? dietPlan;
  bool isLoading = true;
  int _selectedMealTab = 0;

  // -------------------- Zuri Theme --------------------
  static const Color blush = Color(0xFFFFF5F7);
  static const Color rose = Color(0xFFFAD7E0);
  static const Color deepRose = Color(0xFFE88AAE);
  static const Color berry = Color(0xFFB85C7A);
  static const Color plum = Color(0xFF6D435A);
  static const Color cream = Color(0xFFFFFBFC);
  static const Color mint = Color(0xFFDDF5E3);
  static const Color peach = Color(0xFFFFE7D6);
  static const Color lavender = Color(0xFFF0E7FF);

  @override
  void initState() {
    super.initState();
    _loadDietPlan();
  }

  Future<void> _loadDietPlan() async {
    setState(() => isLoading = true);

    try {
      final data = await _firestore.getUserData();
      final latest = await _firestore.getLatestProgress();

      if (!mounted) return;

      if (data == null) {
        setState(() {
          userData = null;
          latestProgress = null;
          dietPlan = null;
          isLoading = false;
        });
        return;
      }

      final plan = _dietService.getDietPlan(
        goal: (data['goal'] ?? '').toString(),
        activity: (data['activity'] ?? '').toString(),
        weight: (data['weight'] ?? '').toString(),
        height: (data['height'] ?? '').toString(),
        latestProgress: latest,
        limitations: (data['limitations'] ?? 'None').toString(),
        workoutDays: (data['workoutDays'] ?? '3 days/week').toString(),
        workoutIntensity: (data['workoutIntensity'] ?? 'Moderate').toString(),
      );

      setState(() {
        userData = data;
        latestProgress = latest;
        dietPlan = plan;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load diet recommendation: $e')),
      );
    }
  }

  String _latestNotesText() {
    final notes = (latestProgress?['notes'] ?? '').toString().trim();
    if (notes.isEmpty) return '';
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blush,
      appBar: AppBar(
        backgroundColor: blush,
        elevation: 0,
        title: const Text(
          'Diet Recommendation',
          style: TextStyle(color: plum, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: plum),
        actions: [
          IconButton(
            onPressed: _loadDietPlan,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: plum),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: berry))
          : dietPlan == null
          ? _buildNoDataState()
          : RefreshIndicator(
              color: berry,
              onRefresh: _loadDietPlan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),

                    _buildSummaryTile(),
                    const SizedBox(height: 20),

                    _buildSectionLabel('Daily Targets'),
                    const SizedBox(height: 10),
                    _buildTargetsGrid(),
                    const SizedBox(height: 20),

                    _buildMealPlanSection(),
                    const SizedBox(height: 20),

                    _buildTipsSection(),
                    const SizedBox(height: 20),

                    if (dietPlan!.hasBloatingSupport) ...[
                      _buildBloatingSupportTile(),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionLabel('Hydration & What to Limit'),
                    const SizedBox(height: 10),
                    _buildHydrationAndAvoid(),
                  ],
                ),
              ),
            ),
    );
  }

  // -------------------- Hero --------------------

  Widget _buildHeroCard() {
    final goal = (userData?['goal'] ?? 'Wellness').toString();
    final activity = (userData?['activity'] ?? '').toString();
    final note = _latestNotesText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepRose, berry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: berry.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Zuri Diet Plan 🍽️',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroBadge('🎯 $goal'),
              if (activity.isNotEmpty) _heroBadge('⚡ $activity'),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Latest note: "$note"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  // -------------------- Summary --------------------

  Widget _buildSummaryTile() {
    return Container(
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: rose,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: plum, size: 20),
          ),
          title: const Text(
            'Your Meal Direction',
            style: TextStyle(
              color: plum,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          iconColor: berry,
          collapsedIconColor: plum,
          initiallyExpanded: true,
          children: [
            Text(
              dietPlan!.summary,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.5,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Targets --------------------

  Widget _buildTargetsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTargetCard(
                title: 'Calories',
                value: dietPlan!.calorieTarget,
                icon: Icons.local_fire_department_rounded,
                color: peach,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTargetCard(
                title: 'Protein',
                value: dietPlan!.proteinTarget,
                icon: Icons.egg_alt_rounded,
                color: mint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: plum),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: plum,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Meal Plan Tabs --------------------

  Widget _buildMealPlanSection() {
    final meals = [
      ('Breakfast', dietPlan!.breakfastOptions, Icons.free_breakfast_rounded, rose),
      ('Lunch', dietPlan!.lunchOptions, Icons.lunch_dining_rounded, peach),
      ('Dinner', dietPlan!.dinnerOptions, Icons.dinner_dining_rounded, lavender),
      ('Snacks', dietPlan!.snackOptions, Icons.apple_rounded, mint),
    ];

    final selected = meals[_selectedMealTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Meal Plan'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(meals.length, (i) {
              final isSelected = i == _selectedMealTab;
              return GestureDetector(
                onTap: () => setState(() => _selectedMealTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? berry : cream,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: berry.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        meals[i].$3,
                        color: isSelected ? Colors.white : plum,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        meals[i].$1,
                        style: TextStyle(
                          color: isSelected ? Colors.white : plum,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        _buildMealListCard(selected.$2, icon: selected.$3, color: selected.$4),
      ],
    );
  }

  Widget _buildMealListCard(
    List<String> items, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: plum, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.55,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 8),
                Divider(color: blush, thickness: 1),
                const SizedBox(height: 8),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  // -------------------- Tips --------------------

  Widget _buildTipsSection() {
    return Container(
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: rose,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: plum, size: 20),
          ),
          title: const Text(
            'Zuri Meal Tips',
            style: TextStyle(
              color: plum,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Tap to expand smart eating tips',
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          iconColor: berry,
          collapsedIconColor: plum,
          children: dietPlan!.mealTips.asMap().entries.map((entry) {
            final isLast = entry.key == dietPlan!.mealTips.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 26,
                      width: 26,
                      decoration: const BoxDecoration(
                        color: rose,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: berry,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 10),
                  Divider(color: blush, thickness: 1),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // -------------------- Bloating Support --------------------

  Widget _buildBloatingSupportTile() {
    return Container(
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.spa_rounded, color: plum, size: 20),
          ),
          title: const Text(
            'Bloating Support',
            style: TextStyle(
              color: plum,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Tap to expand gentle-digestion guidance',
            style: TextStyle(color: plum, fontSize: 12),
          ),
          iconColor: plum,
          collapsedIconColor: plum,
          children: [
            Text(
              dietPlan!.bloatingInsight,
              style: const TextStyle(
                color: plum,
                fontSize: 14.5,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (dietPlan!.bloatingFoodsToPrefer.isNotEmpty) ...[
              const SizedBox(height: 16),
              _bloatingSubHeader('Prefer these for the next few meals'),
              const SizedBox(height: 10),
              ...dietPlan!.bloatingFoodsToPrefer.map(
                (item) => _bloatingRow(item, Icons.favorite_rounded),
              ),
            ],
            if (dietPlan!.bloatingFoodsToReduce.isNotEmpty) ...[
              const SizedBox(height: 16),
              _bloatingSubHeader('Reduce / watch out for'),
              const SizedBox(height: 10),
              ...dietPlan!.bloatingFoodsToReduce.map(
                (item) => _bloatingRow(item, Icons.remove_circle_outline_rounded),
              ),
            ],
            if (dietPlan!.bloatingMealIdeas.isNotEmpty) ...[
              const SizedBox(height: 16),
              _bloatingSubHeader('Suggested anti-bloating meals'),
              const SizedBox(height: 10),
              ...dietPlan!.bloatingMealIdeas.map(
                (item) => _bloatingRow(item, Icons.restaurant_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bloatingSubHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: plum,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  Widget _bloatingRow(String item, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: berry, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(color: plum, fontSize: 14.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Hydration & Avoid --------------------

  Widget _buildHydrationAndAvoid() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lavender,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.water_drop_rounded, color: plum),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dietPlan!.hydrationTarget,
                      style: const TextStyle(
                        color: plum,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dietPlan!.hydrationTip,
                      style: const TextStyle(
                        color: plum,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.block_rounded, color: berry, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Limit / Watch Out For',
                    style: TextStyle(
                      color: plum,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: dietPlan!.avoidOrLimit.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: peach,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: plum,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------- Shared --------------------

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: plum,
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu_rounded, size: 56, color: berry),
              SizedBox(height: 14),
              Text(
                'No profile data found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: plum,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Complete your onboarding so Zuri can build your personalized diet plan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
