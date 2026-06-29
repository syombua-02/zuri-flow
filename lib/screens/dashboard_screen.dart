import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'recommendations_screen.dart';
import 'progress_tracker_screen.dart';
import 'diet_recommendation_screen.dart';

class DashboardScreen extends StatefulWidget {
  /// Called with the target tab index (1 = Pilates, 2 = Diet, 3 = Progress)
  /// when the user taps one of the dashboard's quick-access buttons.
  /// If null (e.g. when DashboardScreen is used standalone), those buttons
  /// fall back to pushing the screen as a normal route.
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userData;
  Map<String, dynamic>? latestProgress;
  List<Map<String, dynamic>> progressEntries = [];
  bool isLoading = true;

  // -------------------- Zuri Flow Theme --------------------
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
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);

    try {
      final data = await _firestore.getUserData();
      final latest = await _firestore.getLatestProgress();
      final history = await _firestore.getProgressEntries();

      if (!mounted) return;

      setState(() {
        userData = data;
        latestProgress = latest;
        progressEntries = history;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load dashboard: $e')));
    }
  }

  // -------------------- Recommendation Logic --------------------

  String getWorkout(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return '30 min cardio + 20 min full body circuit + evening walk';
      case 'Muscle Gain':
        return 'Strength training split: upper/lower body + progressive overload';
      case 'Toning':
        return 'Pilates + light dumbbell training + core sculpt session';
      default:
        return 'Light yoga, stretching and a 20-minute walk';
    }
  }

  bool _notesSuggestBloating() {
    final notes = (latestProgress?['notes'] ?? '').toString().toLowerCase();
    return notes.contains('bloated') ||
        notes.contains('bloating') ||
        notes.contains('gassy') ||
        notes.contains('gas') ||
        notes.contains('constipation') ||
        notes.contains('constipated') ||
        notes.contains('stomach');
  }

  bool _notesSuggestLowEnergy() {
    final notes = (latestProgress?['notes'] ?? '').toString().toLowerCase();
    return notes.contains('tired') ||
        notes.contains('low energy') ||
        notes.contains('fatigue') ||
        notes.contains('weak') ||
        notes.contains('drained');
  }

  String getDietPreview() {
    final goal = (userData?['goal'] ?? '').toString();
    final bloated = _notesSuggestBloating();
    final lowEnergy = _notesSuggestLowEnergy();

    if (goal == 'Weight Loss') {
      if (bloated) {
        return 'Focus on lighter fat-loss meals today: grilled chicken or fish, rice/sweet potato in moderate portions, cooked vegetables, and ginger/peppermint tea. Reduce salty snacks and fizzy drinks.';
      }
      if (lowEnergy) {
        return 'Keep weight-loss meals balanced today: don’t skip breakfast. Aim for eggs/oats in the morning, a protein + vegetable lunch, and a lighter but complete dinner.';
      }
      return 'High-protein, portion-aware meals: eggs/oats for breakfast, chicken/fish + vegetables + moderate ugali/rice for lunch, and a lighter protein-based dinner.';
    }

    if (goal == 'Muscle Gain') {
      if (bloated) {
        return 'Keep muscle-gain meals easier to digest today: eggs, chicken/fish, rice, sweet potato, cooked vegetables, and avoid very greasy heavy meals.';
      }
      if (lowEnergy) {
        return 'You likely need better workout fuel: include proper carbs with protein at breakfast, lunch and post-workout meals instead of relying on snacks only.';
      }
      return 'Prioritize full meals with protein + carbs: eggs/oats/milk for breakfast, chicken/beef + rice/ugali for lunch, and a solid recovery dinner.';
    }

    if (goal == 'Toning') {
      if (bloated) {
        return 'Keep meals lean but gentle on digestion: eggs or fish, moderate rice/arrowroots/sweet potato, cooked vegetables, and good hydration to reduce puffiness.';
      }
      if (lowEnergy) {
        return 'For toning, don’t under-eat. Keep protein steady and include enough carbs around workouts so you can train well and recover.';
      }
      return 'Balanced recomposition meals: protein at every meal, moderate carbs, vegetables at lunch and dinner, and smarter snacks instead of random grazing.';
    }

    if (bloated) {
      return 'Go for simpler balanced meals today: eggs or chicken, rice/sweet potato, cooked vegetables, and more water/ginger tea.';
    }

    return 'A balanced plate works best today: protein + vegetables + a moderate carb source, plus steady hydration.';
  }

  String getFocusTip(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return 'Focus on consistency today: movement + hydration + portion awareness.';
      case 'Muscle Gain':
        return 'Prioritize protein intake and make sure you recover well after training.';
      case 'Toning':
        return 'Keep your posture strong, core engaged, and don’t skip your stretching.';
      default:
        return 'Choose gentle movement, nourishing meals, and enough rest today.';
    }
  }

  String getGoalEmoji(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return '🔥';
      case 'Muscle Gain':
        return '💪';
      case 'Toning':
        return '✨';
      default:
        return '🌿';
    }
  }

  String getFirstName() {
    final saved = (userData?['name'] ?? '').toString().trim();
    if (saved.isNotEmpty) return saved;

    final email = _auth.currentUser?.email ?? '';
    if (email.isEmpty) return 'Beautiful';

    final namePart = email.split('@').first.replaceAll(RegExp(r'[0-9]'), '').trim();
    if (namePart.isEmpty) return 'Beautiful';

    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  String _displayValue(dynamic value, {String suffix = ''}) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '—';
    return '$text$suffix';
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString().trim()) ?? 0;
  }

  bool _hasValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isNotEmpty && double.tryParse(text) != null;
  }

  String getProgressMessage(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return 'Small daily habits create visible results. Stay consistent.';
      case 'Muscle Gain':
        return 'Strength builds over time — keep showing up and eating well.';
      case 'Toning':
        return 'Toning is all about consistency, control, and recovery.';
      default:
        return 'Every healthy choice counts. Keep flowing at your own pace.';
    }
  }

  String getLatestProgressInsight() {
    if (latestProgress == null) {
      return 'No check-in yet — start tracking to see your trends here.';
    }
    if (progressEntries.length < 2) {
      return 'Add one more check-in to unlock progress comparisons.';
    }
    final latest = progressEntries[0];
    final previous = progressEntries[1];
    List<String> improvements = [];
    if (_hasValue(latest['weight']) && _hasValue(previous['weight'])) {
      final diff = _toDouble(latest['weight']) - _toDouble(previous['weight']);
      if (diff < 0) { improvements.add('weight ↓ ${diff.abs().toStringAsFixed(1)} kg'); }
      else if (diff > 0) { improvements.add('weight ↑ ${diff.abs().toStringAsFixed(1)} kg'); }
    }
    if (_hasValue(latest['waist']) && _hasValue(previous['waist'])) {
      final diff = _toDouble(latest['waist']) - _toDouble(previous['waist']);
      if (diff < 0) { improvements.add('waist ↓ ${diff.abs().toStringAsFixed(1)} in'); }
      else if (diff > 0) { improvements.add('waist ↑ ${diff.abs().toStringAsFixed(1)} in'); }
    }
    if (improvements.isNotEmpty) { return improvements.join('  ·  '); }
    return 'Measurements are holding steady — keep going.';
  }

  String getProgressTrendSummary() {
    if (progressEntries.length < 2) {
      return 'Log one more check-in to unlock your trend view.';
    }
    final latest = progressEntries[0];
    final previous = progressEntries[1];
    List<String> trends = [];
    if (_hasValue(latest['weight']) && _hasValue(previous['weight'])) {
      final diff = _toDouble(latest['weight']) - _toDouble(previous['weight']);
      if (diff < 0) { trends.add('Weight ↓ ${diff.abs().toStringAsFixed(1)} kg'); }
      else if (diff > 0) { trends.add('Weight ↑ ${diff.abs().toStringAsFixed(1)} kg'); }
    }
    if (_hasValue(latest['waist']) && _hasValue(previous['waist'])) {
      final diff = _toDouble(latest['waist']) - _toDouble(previous['waist']);
      if (diff < 0) { trends.add('Waist ↓ ${diff.abs().toStringAsFixed(1)} in'); }
      else if (diff > 0) { trends.add('Waist ↑ ${diff.abs().toStringAsFixed(1)} in'); }
    }
    if (_hasValue(latest['hips']) && _hasValue(previous['hips'])) {
      final diff = _toDouble(latest['hips']) - _toDouble(previous['hips']);
      if (diff < 0) { trends.add('Hips ↓ ${diff.abs().toStringAsFixed(1)} in'); }
      else if (diff > 0) { trends.add('Hips ↑ ${diff.abs().toStringAsFixed(1)} in'); }
    }
    if (trends.isEmpty) { return 'Measurements are holding steady this week.'; }
    return trends.join('  ·  ');
  }


  Future<void> logout() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void goToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen(isEditing: true)),
    ).then((_) => loadUserData());
  }

  void goToRecommendations() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(1);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
    );
  }

  void goToProgressTracker() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(3);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgressTrackerScreen()),
    ).then((_) => loadUserData());
  }

  void goToDietRecommendations() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(2);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DietRecommendationScreen()),
    ).then((_) => loadUserData());
  }

  @override 
  Widget build(BuildContext context) {
    final String userName = getFirstName();

    return Scaffold(
      backgroundColor: blush,
      appBar: AppBar(
        backgroundColor: blush,
        elevation: 0,
        title: const Text(
          'Zuri Flow',
          style: TextStyle(color: plum, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: plum),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: berry))
          : userData == null
          ? _buildNoDataState()
          : RefreshIndicator(
              color: berry,
              onRefresh: loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(userName),
                    const SizedBox(height: 16),

                    _buildSectionTitle('Your Wellness Snapshot'),
                    const SizedBox(height: 10),
                    _buildProfileGrid(),
                    const SizedBox(height: 20),

                    _buildSectionTitle("Your Personalized Plan"),
                    const SizedBox(height: 10),
                    _buildRecommendationCard(
                      title: "Today’s Workout",
                      subtitle: getWorkout(userData!["goal"] ?? ""),
                      icon: Icons.fitness_center_rounded,
                      cardColor: rose,
                      onTap: goToRecommendations,
                    ),
                    const SizedBox(height: 14),
                    _buildRecommendationCard(
                      title: "Today’s Meal Direction",
                      subtitle: getDietPreview(),
                      icon: Icons.restaurant_menu_rounded,
                      cardColor: peach,
                      onTap: goToDietRecommendations,
                    ),
                    const SizedBox(height: 20),

                    _buildSectionTitle("Today’s Focus"),
                    const SizedBox(height: 10),
                    _buildFocusCard(),
                    const SizedBox(height: 20),

                    _buildSectionTitle("Progress & Motivation"),
                    const SizedBox(height: 10),
                    _buildProgressCard(),
                    const SizedBox(height: 20),

                    _buildSectionTitle("Latest Progress Snapshot"),
                    const SizedBox(height: 10),
                    _buildLatestProgressCard(),
                    const SizedBox(height: 14),

                    _buildSectionTitle("Progress Trend"),
                    const SizedBox(height: 10),
                    _buildTrendCard(),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: goToEditProfile,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: berry),
                          foregroundColor: berry,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // -------------------- UI Widgets --------------------

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.spa_rounded, size: 56, color: berry),
              const SizedBox(height: 14),
              const Text(
                'Your Zuri profile is empty',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: plum,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete your onboarding so Zuri Flow can build your personalized plan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: goToEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: berry,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Complete My Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: plum,
      ),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    final goal = userData?['goal']?.toString() ?? 'Wellness';
    final emoji = getGoalEmoji(goal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepRose, berry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: berry.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $userName $emoji',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your goal is $goal — and today is a good day to move, nourish your body, and stay in flow.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'Goal',
                value: userData?['goal']?.toString() ?? '—',
                icon: Icons.flag_rounded,
                bgColor: rose,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                title: 'Activity',
                value: userData?['activity']?.toString() ?? '—',
                icon: Icons.directions_run_rounded,
                bgColor: mint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'Weight',
                value: '${userData?['weight']?.toString() ?? '—'} kg',
                icon: Icons.monitor_weight_rounded,
                bgColor: peach,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                title: 'Height',
                value: (userData?['height']?.toString().trim().isEmpty ?? true) ? '—' : userData!['height'].toString(),
                icon: Icons.height_rounded,
                bgColor: lavender,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
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
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: plum),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: plum,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: plum),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: plum,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.4,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black26,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard() {
    final goal = userData?['goal']?.toString() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: berry,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              getFocusTip(goal),
              style: const TextStyle(
                color: plum,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final goal = userData?['goal']?.toString() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F4), Color(0xFFFFFBFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
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
          Text(
            getProgressMessage(goal),
            style: const TextStyle(
              color: plum,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: rose,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_rounded, color: berry, size: 15),
                SizedBox(width: 6),
                Text(
                  'Soft progress is still progress',
                  style: TextStyle(
                    color: berry,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    final summary = getProgressTrendSummary();
    final hasTrends = summary.contains('↑') || summary.contains('↓');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lavender,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: hasTrends
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.split('  ·  ').map((part) {
                final isDown = part.contains('↓');
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isDown ? mint : peach,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    part.trim(),
                    style: TextStyle(
                      color: isDown ? const Color(0xFF2D7A5B) : berry,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            )
          : Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: plum, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    summary,
                    style: const TextStyle(
                      color: plum,
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLatestProgressCard() {
    if (latestProgress == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'No progress check-in yet. Tap "Track My Progress" to save your first weight and measurements.',
          style: TextStyle(color: Colors.black87, height: 1.6, fontSize: 14.5),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatChip(
                'Weight',
                _displayValue(latestProgress!['weight'], suffix: ' kg'),
              ),
              _buildStatChip(
                'Waist',
                _displayValue(latestProgress!['waist'], suffix: ' in'),
              ),
              _buildStatChip(
                'Hips',
                _displayValue(latestProgress!['hips'], suffix: ' in'),
              ),
              _buildStatChip(
                'Bust',
                _displayValue(latestProgress!['bust'], suffix: ' in'),
              ),
              _buildStatChip(
                'Thigh',
                _displayValue(latestProgress!['thigh'], suffix: ' in'),
              ),
              _buildStatChip(
                'Arm',
                _displayValue(latestProgress!['arm'], suffix: ' in'),
              ),
            ],
          ),
          ..._buildTrendBadges().isNotEmpty
              ? [
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildTrendBadges(),
                  ),
                ]
              : [],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: lavender,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded, color: plum, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    getLatestProgressInsight(),
                    style: const TextStyle(
                      color: plum,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if ((latestProgress!['notes'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: blush,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                latestProgress!['notes'].toString().trim(),
                style: const TextStyle(
                  color: plum,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTrendBadges() {
    if (progressEntries.length < 2) return [];
    final latest = progressEntries[0];
    final previous = progressEntries[1];
    final badges = <Widget>[];

    void addBadge(String label, dynamic lv, dynamic pv, String unit) {
      if (!_hasValue(lv) || !_hasValue(pv)) return;
      final diff = _toDouble(lv) - _toDouble(pv);
      if (diff == 0) return;
      final isDown = diff < 0;
      badges.add(_buildTrendBadge(
        '${isDown ? '↓' : '↑'} $label ${diff.abs().toStringAsFixed(1)} $unit',
        isDown,
      ));
    }

    addBadge('Weight', latest['weight'], previous['weight'], 'kg');
    addBadge('Waist', latest['waist'], previous['waist'], 'in');
    addBadge('Hips', latest['hips'], previous['hips'], 'in');
    return badges;
  }

  Widget _buildTrendBadge(String text, bool isDown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDown ? mint : peach,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDown ? const Color(0xFF2D7A5B) : berry,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: rose,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: plum, fontWeight: FontWeight.w600),
      ),
    );
  }
}