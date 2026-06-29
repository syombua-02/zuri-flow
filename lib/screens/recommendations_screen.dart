import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';

class WorkoutVideo {
  final String title;
  final String channel;
  final String type;
  final String duration;
  final String level;
  final List<String> goals;
  final List<String> activityLevels;
  final List<String> focusAreas;
  final List<String> tags;
  final String url;

  const WorkoutVideo({
    required this.title,
    required this.channel,
    required this.type,
    required this.duration,
    required this.level,
    required this.goals,
    required this.activityLevels,
    required this.focusAreas,
    required this.tags,
    required this.url,
  });
}

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => RecommendationsScreenState();
}

class RecommendationsScreenState extends State<RecommendationsScreen> {
  final FirestoreService _firestore = FirestoreService();

  Map<String, dynamic>? userData;
  Map<String, dynamic>? latestProgress;
  List<Map<String, dynamic>> progressEntries = [];
  bool isLoading = true;

  static const Color blush = Color(0xFFFFF5F7);
  static const Color rose = Color(0xFFFAD7E0);
  static const Color deepRose = Color(0xFFE88AAE);
  static const Color berry = Color(0xFFB85C7A);
  static const Color plum = Color(0xFF6D435A);
  static const Color cream = Color(0xFFFFFBFC);
  static const Color mint = Color(0xFFDDF5E3);
  static const Color peach = Color(0xFFFFE7D6);
  static const Color lavender = Color(0xFFF0E7FF);

  final List<WorkoutVideo> videoDatabase = const [
    WorkoutVideo(
      title: '30 MIN PILATES WORKOUT || Beginner to Moderate Pilates',
      channel: 'Move With Nicole',
      type: 'Pilates',
      duration: '30 min',
      level: 'Beginner–Moderate',
      goals: ['Weight Loss', 'Toning', 'Healthy Living'],
      activityLevels: ['Beginner', 'Moderate'],
      focusAreas: ['Full Body', 'Core', 'Posture'],
      tags: ['low impact', 'full body', 'no equipment', 'consistency'],
      url: 'https://www.youtube.com/watch?v=wtVyZmHnlxM',
    ),
    WorkoutVideo(
      title: '20 MIN EXPRESS PILATES WORKOUT',
      channel: 'Move With Nicole',
      type: 'Pilates',
      duration: '20 min',
      level: 'Beginner',
      goals: ['Weight Loss', 'Toning', 'Healthy Living'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Full Body', 'Core'],
      tags: ['short', 'beginner', 'low impact', 'busy day'],
      url: 'https://www.youtube.com/watch?v=y2RcYo36boM',
    ),
    WorkoutVideo(
      title: 'Full Body Pilates Flow',
      channel: 'Lottie Murphy',
      type: 'Pilates',
      duration: '25 min',
      level: 'Beginner–Moderate',
      goals: ['Healthy Living', 'Toning'],
      activityLevels: ['Beginner', 'Moderate'],
      focusAreas: ['Full Body', 'Posture', 'Flexibility'],
      tags: ['gentle', 'flow', 'wellness', 'posture'],
      url: 'https://www.youtube.com/watch?v=vQzdEqRXd9M',
    ),
    WorkoutVideo(
      title: 'Beginner Pilates Workout',
      channel: 'Jessica Valant Pilates',
      type: 'Pilates',
      duration: '20 min',
      level: 'Beginner',
      goals: ['Healthy Living', 'Toning'],
      activityLevels: ['Beginner'],
      focusAreas: ['Full Body', 'Posture', 'Core'],
      tags: ['beginner', 'gentle', 'safe', 'form'],
      url: 'https://www.youtube.com/watch?v=bU_lV1TOw4U',
    ),
    WorkoutVideo(
      title: 'Pilates for Core Strength',
      channel: 'Jessica Valant Pilates',
      type: 'Pilates',
      duration: '20 min',
      level: 'Beginner–Moderate',
      goals: ['Toning', 'Muscle Gain', 'Healthy Living'],
      activityLevels: ['Beginner', 'Moderate'],
      focusAreas: ['Core', 'Posture'],
      tags: ['core', 'strength', 'control'],
      url: 'https://www.youtube.com/results?search_query=jessica+valant+pilates+core+strength',
    ),
    WorkoutVideo(
      title: '20 Minute Pilates Abs / Deep Core Workout',
      channel: 'Pilates By Izzy (@izzy.samuel)',
      type: 'Pilates',
      duration: '20 min',
      level: 'Intermediate',
      goals: ['Toning', 'Weight Loss'],
      activityLevels: ['Moderate', 'Active'],
      focusAreas: ['Core'],
      tags: ['abs', 'deep core', 'tone', 'sculpt'],
      url: 'https://www.youtube.com/watch?v=XmbOXzKIjaU',
    ),
    WorkoutVideo(
      title: 'Full Body Pilates X Strength',
      channel: 'Pilates By Izzy (@izzy.samuel)',
      type: 'Pilates',
      duration: '30 min',
      level: 'Intermediate',
      goals: ['Toning', 'Muscle Gain', 'Weight Loss'],
      activityLevels: ['Moderate', 'Active'],
      focusAreas: ['Full Body', 'Glutes', 'Core'],
      tags: ['strength', 'sculpt', 'challenge', 'sweat'],
      url: 'https://www.youtube.com/watch?v=nkc7upm5naA',
    ),
    WorkoutVideo(
      title: 'Full Body Strength Pilates With Weights',
      channel: 'Pilates By Izzy (@izzy.samuel)',
      type: 'Pilates',
      duration: '30-40 min',
      level: 'Intermediate–Advanced',
      goals: ['Muscle Gain', 'Toning'],
      activityLevels: ['Active'],
      focusAreas: ['Full Body', 'Glutes', 'Arms'],
      tags: ['weights', 'strength', 'progressive', 'challenging'],
      url: 'https://www.youtube.com/watch?v=XnNuClyOxxo',
    ),
    WorkoutVideo(
      title: 'Pilates Booty Burn',
      channel: 'Bailey Brown',
      type: 'Pilates',
      duration: '15-20 min',
      level: 'Moderate',
      goals: ['Toning', 'Muscle Gain'],
      activityLevels: ['Moderate', 'Active'],
      focusAreas: ['Glutes'],
      tags: ['glutes', 'booty', 'lower body', 'burn'],
      url: 'https://www.youtube.com/watch?v=ouqpYvEWoqI',
    ),
    WorkoutVideo(
      title: 'Beginner Friendly Full Body Pilates',
      channel: 'Flow with Mira',
      type: 'Pilates',
      duration: '20-30 min',
      level: 'Beginner–Moderate',
      goals: ['Healthy Living', 'Toning', 'Weight Loss'],
      activityLevels: ['Beginner', 'Moderate'],
      focusAreas: ['Full Body', 'Core'],
      tags: ['beginner', 'flow', 'full body', 'gentle'],
      url: 'https://www.youtube.com/watch?v=keIiMG1kKx0',
    ),
    WorkoutVideo(
      title: 'Morning Yoga for Beginners',
      channel: 'Yoga With Adriene',
      type: 'Yoga',
      duration: '15-25 min',
      level: 'Beginner',
      goals: ['Healthy Living'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Stress Relief', 'Flexibility', 'Posture'],
      tags: ['morning', 'gentle', 'stress relief', 'mobility'],
      url: 'https://www.youtube.com/watch?v=GnHTeHAZQhM',
    ),
    WorkoutVideo(
      title: 'Yoga for Complete Beginners',
      channel: 'Yoga With Adriene',
      type: 'Yoga',
      duration: '20 min',
      level: 'Beginner',
      goals: ['Healthy Living'],
      activityLevels: ['Beginner'],
      focusAreas: ['Flexibility', 'Stress Relief', 'Posture'],
      tags: ['beginner', 'gentle', 'breathing', 'confidence'],
      url: 'https://www.youtube.com/watch?v=v7AYKMP6rOE',
    ),
    WorkoutVideo(
      title: 'Yoga for Digestion / Bloating Relief',
      channel: 'Yoga With Adriene',
      type: 'Yoga',
      duration: '15-25 min',
      level: 'Beginner',
      goals: ['Healthy Living', 'Weight Loss', 'Toning'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Stress Relief', 'Flexibility'],
      tags: ['bloating', 'digestion', 'gentle', 'recovery'],
      url: 'https://www.youtube.com/watch?v=hbguV_f6XOo',
    ),
    WorkoutVideo(
      title: 'Full Body Stretch for Flexibility',
      channel: 'Charlie Follows',
      type: 'Yoga / Stretch',
      duration: '20-30 min',
      level: 'All levels',
      goals: ['Healthy Living', 'Toning'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Flexibility', 'Posture', 'Stress Relief'],
      tags: ['stretch', 'mobility', 'recovery', 'flexibility'],
      url: 'https://www.youtube.com/watch?v=KjednnUNNjA',
    ),
    WorkoutVideo(
      title: 'Gentle Yoga Flow for Stress Relief',
      channel: 'Boho Beautiful Yoga',
      type: 'Yoga',
      duration: '20-30 min',
      level: 'Beginner–Moderate',
      goals: ['Healthy Living'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Stress Relief', 'Flexibility'],
      tags: ['gentle', 'stress relief', 'calm', 'wellness'],
      url: 'https://www.youtube.com/watch?v=e4HBS4cT15o',
    ),
    WorkoutVideo(
      title: 'Gentle Yoga for Low Energy Days',
      channel: 'SarahBethYoga',
      type: 'Yoga',
      duration: '10-20 min',
      level: 'Beginner',
      goals: ['Healthy Living', 'Weight Loss', 'Toning'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Stress Relief', 'Flexibility'],
      tags: ['low energy', 'gentle', 'recovery', 'easy'],
      url: 'https://www.youtube.com/watch?v=UsK8L3VA3VU',
    ),
    WorkoutVideo(
      title: 'Mobility Routine for Tight Hips and Back',
      channel: 'Tom Merrick',
      type: 'Mobility',
      duration: '15-25 min',
      level: 'All levels',
      goals: ['Healthy Living', 'Toning', 'Muscle Gain'],
      activityLevels: ['Beginner', 'Moderate', 'Active'],
      focusAreas: ['Flexibility', 'Posture'],
      tags: ['mobility', 'back pain', 'hips', 'recovery'],
      url: 'https://www.youtube.com/watch?v=jj2AAH6jbHk',
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load recommendations: $e')),
      );
    }
  }

  double? parseNumber(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().trim());
  }

  double? parseHeightToMeters(String heightStr) {
    final cleaned = heightStr.trim().replaceAll('"', '');
    if (cleaned.contains("'")) {
      final parts = cleaned.split("'");
      if (parts.length >= 2) {
        final feet = double.tryParse(parts[0].trim());
        final inches = double.tryParse(parts[1].trim());
        if (feet != null && inches != null) {
          return (feet * 12 + inches) * 0.0254;
        }
      }
    }
    // fallback: plain number treated as cm
    final h = double.tryParse(cleaned);
    if (h != null && h > 0) return h / 100;
    return null;
  }

  double? calculateBmi({required String weight, required String height}) {
    final w = parseNumber(weight);
    final heightM = parseHeightToMeters(height);

    if (w == null || heightM == null || w <= 0 || heightM <= 0) return null;

    return w / (heightM * heightM);
  }

  String getBmiCategory(double? bmi) {
    if (bmi == null) return 'Not enough data';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy Range';
    if (bmi < 30) return 'Overweight';
    return 'Higher Weight Range';
  }

  bool notesContain(String word) {
    final notes = (latestProgress?['notes'] ?? '').toString().toLowerCase();
    return notes.contains(word);
  }

  bool get needsRecovery {
    return notesContain('bloated') ||
        notesContain('bloating') ||
        notesContain('tired') ||
        notesContain('low energy') ||
        notesContain('sore') ||
        notesContain('pain') ||
        notesContain('stomach');
  }

  bool get feelsStrong {
    final notes = (latestProgress?['notes'] ?? '').toString().toLowerCase();
    return notes.contains('strong') ||
        notes.contains('better') ||
        notes.contains('energized') ||
        notes.contains('good');
  }

  int getMatchScore(WorkoutVideo video) {
    final goal = (userData?['goal'] ?? '').toString();
    final activity = (userData?['activity'] ?? '').toString();
    final movementPreference =
        (userData?['movementPreference'] ?? 'Pilates + Yoga').toString();
    final workoutIntensity =
        (userData?['workoutIntensity'] ?? 'Moderate').toString();
    final focusArea = (userData?['focusArea'] ?? 'Full Body').toString();
    final equipment = (userData?['equipment'] ?? 'None').toString();
    final limitations = (userData?['limitations'] ?? 'None').toString();

    int score = 50;

    // ── Goal (major) ──────────────────────────────────────────
    if (video.goals.contains(goal)) score += 20;

    // ── Activity level (major) ────────────────────────────────
    if (video.activityLevels.contains(activity)) score += 12;

    // ── Focus area ────────────────────────────────────────────
    if (video.focusAreas.contains(focusArea)) score += 12;
    if (focusArea == 'Glutes' && video.focusAreas.contains('Glutes')) score += 8;
    if (focusArea == 'Core' && video.focusAreas.contains('Core')) score += 6;
    if (focusArea == 'Flexibility' &&
        (video.type.contains('Yoga') || video.type.contains('Mobility'))) {
      score += 8;
    }
    if (focusArea == 'Stress Relief' && video.type.contains('Yoga')) score += 10;

    // ── Movement preference (STRICT — the main filter) ────────
    final isPilates = video.type.contains('Pilates');
    final isYoga = video.type.contains('Yoga');
    final isMobility =
        video.type.contains('Mobility') || video.type.contains('Stretch');

    switch (movementPreference) {
      case 'Pilates':
        if (isPilates) { score += 20; }
        else if (isYoga) { score -= 30; }
        else if (isMobility) { score -= 15; }
        break;
      case 'Yoga':
        if (isYoga) { score += 20; }
        else if (isPilates) { score -= 20; }
        else if (isMobility) { score += 5; }
        break;
      case 'Pilates + Yoga':
        if (isPilates || isYoga) { score += 12; }
        else if (isMobility) { score -= 5; }
        break;
      case 'Stretching + Mobility':
        if (isMobility) { score += 20; }
        else if (isYoga && video.tags.contains('gentle')) { score += 8; }
        else if (isPilates && video.tags.contains('challenge')) { score -= 15; }
        else if (isPilates) { score -= 5; }
        break;
    }

    // ── Workout intensity ─────────────────────────────────────
    switch (workoutIntensity) {
      case 'Gentle':
        if (video.level.contains('Beginner') ||
            video.tags.contains('gentle') ||
            video.tags.contains('recovery')) { score += 15; }
        if (video.level.contains('Intermediate') ||
            video.level.contains('Advanced')) { score -= 20; }
        if (video.tags.contains('challenge') ||
            video.tags.contains('sweat')) { score -= 20; }
        break;
      case 'Moderate':
        if (video.level.contains('Moderate') ||
            video.level == 'Beginner–Moderate') { score += 10; }
        if (video.level.contains('Intermediate')) { score -= 5; }
        break;
      case 'Challenging':
        if (video.level.contains('Intermediate') ||
            video.level.contains('Advanced')) { score += 15; }
        if (video.tags.contains('challenge') ||
            video.tags.contains('strength') ||
            video.tags.contains('sculpt')) { score += 10; }
        if (video.level == 'Beginner') { score -= 10; }
        break;
    }

    // ── Equipment ─────────────────────────────────────────────
    if (equipment == 'None' && video.tags.contains('weights')) { score -= 20; }
    if (equipment.contains('Dumbbells') && video.tags.contains('weights')) {
      score += 10;
    }

    // ── Limitations (type-specific, can strongly override) ────
    switch (limitations) {
      case 'Knee Pain':
        if (video.tags.contains('low impact') ||
            video.type.contains('Yoga') ||
            video.type.contains('Mobility')) { score += 20; }
        if (isPilates && video.tags.contains('gentle')) { score += 10; }
        if (video.tags.contains('challenge') ||
            video.tags.contains('sweat')) { score -= 25; }
        break;
      case 'Back Pain':
        if (video.type.contains('Yoga') ||
            video.type.contains('Mobility')) { score += 22; }
        if (video.tags.contains('mobility') ||
            video.tags.contains('stretch') ||
            video.tags.contains('recovery')) { score += 15; }
        if (video.tags.contains('weights') ||
            video.tags.contains('challenge')) { score -= 25; }
        break;
      case 'Low Energy':
        if (video.tags.contains('gentle') ||
            video.tags.contains('recovery')) { score += 20; }
        if (video.level.contains('Beginner') ||
            video.level.contains('All')) { score += 10; }
        if (video.tags.contains('challenge') ||
            video.tags.contains('sweat')) { score -= 25; }
        break;
      case 'Bloating':
        if (video.type.contains('Yoga')) { score += 18; }
        if (video.tags.contains('bloating') ||
            video.tags.contains('digestion') ||
            video.tags.contains('gentle')) { score += 15; }
        if (video.tags.contains('challenge') ||
            video.tags.contains('sweat')) { score -= 10; }
        break;
      case 'Beginner Confidence':
        if (video.tags.contains('beginner') ||
            video.level == 'Beginner') { score += 25; }
        if (video.level.contains('Intermediate') ||
            video.level.contains('Advanced')) { score -= 30; }
        break;
    }

    // ── Latest progress notes (dynamic override) ──────────────
    if (needsRecovery) {
      if (video.tags.contains('recovery') ||
          video.tags.contains('gentle') ||
          video.tags.contains('bloating') ||
          video.type.contains('Yoga') ||
          video.type.contains('Mobility')) { score += 20; }
      if (video.tags.contains('challenge') ||
          video.tags.contains('sweat') ||
          video.tags.contains('weights')) { score -= 15; }
    }

    if (feelsStrong) {
      if (video.tags.contains('strength') ||
          video.tags.contains('challenge') ||
          video.tags.contains('sculpt')) { score += 10; }
    }

    return score.clamp(40, 98);
  }

  List<WorkoutVideo> getTopRecommendations() {
    final videos = [...videoDatabase];

    videos.sort((a, b) => getMatchScore(b).compareTo(getMatchScore(a)));

    final selected = <WorkoutVideo>[];
    final usedChannels = <String>{};

    for (final video in videos) {
      if (selected.length >= 5) break;

      if (!usedChannels.contains(video.channel) || selected.length >= 3) {
        selected.add(video);
        usedChannels.add(video.channel);
      }
    }

    return selected;
  }

  List<WorkoutVideo> getWeeklyPlan() {
    final top = getTopRecommendations();

    if (top.isEmpty) return [];

    final plan = <WorkoutVideo>[];

    for (int i = 0; i < 7; i++) {
      plan.add(top[i % top.length]);
    }

    return plan;
  }

  String getCoachMessage() {
    final goal = (userData?['goal'] ?? 'your goal').toString();
    final activity = (userData?['activity'] ?? 'your activity level').toString();
    final focus = (userData?['focusArea'] ?? 'Full Body').toString();

    if (needsRecovery) {
      return 'Your latest progress note suggests your body needs a gentler day. Zuri is prioritising recovery, stretching, yoga, and lighter Pilates while still supporting your goal of $goal.';
    }

    if (feelsStrong) {
      return 'You seem to be feeling stronger, so Zuri is giving you slightly more challenging Pilates options while keeping your focus on $focus.';
    }

    if (goal == 'Healthy Living') {
      return 'For Healthy Living, Zuri is balancing gentle Pilates, yoga, flexibility, posture, and stress-relief instead of pushing only hard sculpt workouts.';
    }

    return 'Zuri selected these videos using your goal of $goal, your activity level of $activity, your focus area, and your latest progress notes.';
  }

  Future<void> openVideo(String url) async {
    final uri = Uri.parse(url);

    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the YouTube link.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open video: $e')));
    }
  }

  Color getAccentColor(WorkoutVideo video) {
    if (video.type.contains('Yoga')) return lavender;
    if (video.type.contains('Mobility')) return mint;
    if (video.focusAreas.contains('Glutes')) return peach;
    if (video.tags.contains('recovery')) return mint;
    return rose;
  }

  @override
  Widget build(BuildContext context) {
    final goal = userData?['goal']?.toString() ?? '';
    final activity = userData?['activity']?.toString() ?? '';
    final weight = userData?['weight']?.toString() ?? '';
    final height = userData?['height']?.toString() ?? '';

    final bmi = calculateBmi(weight: weight, height: height);
    final recommendations = getTopRecommendations();
    final weeklyPlan = getWeeklyPlan();

    return Scaffold(
      backgroundColor: blush,
      appBar: AppBar(
        backgroundColor: blush,
        elevation: 0,
        title: const Text(
          'Pilates Recommendations',
          style: TextStyle(color: plum, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: plum),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: berry))
          : RefreshIndicator(
              color: berry,
              onRefresh: loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(goal, activity, bmi),
                    const SizedBox(height: 18),

                    _buildSectionTitle('Zuri Coach Note'),
                    const SizedBox(height: 10),
                    _buildCoachCard(),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Best Matches For You'),
                    const SizedBox(height: 10),
                    ...List.generate(
                      recommendations.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildVideoCard(recommendations[index], index + 1),
                      ),
                    ),

                    const SizedBox(height: 10),
                    _buildSectionTitle('Your Weekly Plan'),
                    const SizedBox(height: 10),
                    _buildWeeklyPlanCard(weeklyPlan),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroCard(String goal, String activity, double? bmi) {
    final bmiLabel = bmi == null
        ? 'BMI N/A'
        : 'BMI ${bmi.toStringAsFixed(1)} · ${getBmiCategory(bmi)}';

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
            'Your Zuri Movement Plan ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (goal.isNotEmpty) _heroBadge('🎯 $goal'),
              if (activity.isNotEmpty) _heroBadge('⚡ $activity'),
              _heroBadge('📊 $bmiLabel'),
            ],
          ),
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

  Widget _buildCoachCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        getCoachMessage(),
        style: const TextStyle(
          color: plum,
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVideoCard(WorkoutVideo video, int rank) {
    final score = getMatchScore(video);
    final accent = getAccentColor(video);

    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: plum,
                  child: Text('$rank'),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    video.title,
                    style: const TextStyle(
                      color: plum,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildChip(Icons.person_rounded, video.channel),
                    _buildChip(Icons.self_improvement_rounded, video.type),
                    _buildChip(Icons.schedule_rounded, video.duration),
                    _buildChip(Icons.star_rounded, '$score% match'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Why Zuri picked this:',
                  style: const TextStyle(
                    color: plum,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _buildReason(video),
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.6,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => openVideo(video.url),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepRose,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('Watch on YouTube'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildReason(WorkoutVideo video) {
    final goal = (userData?['goal'] ?? '').toString();
    final focus = (userData?['focusArea'] ?? '').toString();

    if (needsRecovery) {
      return 'This is gentler and more recovery-friendly, which matches your latest progress notes while still supporting $goal.';
    }

    if (goal == 'Healthy Living') {
      return 'This supports wellness, posture, flexibility, breathing, and consistency instead of pushing only high-intensity sculpt work.';
    }

    return 'This matches your goal of $goal, your focus area of $focus, and your current workout preferences.';
  }

  String _weeklyPlanTitle() {
    final pref =
        (userData?['movementPreference'] ?? 'Pilates + Yoga').toString().trim();
    switch (pref) {
      case 'Pilates':
        return 'Your 7-Day Pilates Plan';
      case 'Yoga':
        return 'Your 7-Day Yoga Plan';
      case 'Stretching + Mobility':
        return 'Your 7-Day Stretch & Mobility Plan';
      default:
        return 'Your 7-Day Pilates + Yoga Plan';
    }
  }

  Widget _buildWeeklyPlanCard(List<WorkoutVideo> weeklyPlan) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
              color: lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: plum, size: 20),
          ),
          title: Text(
            _weeklyPlanTitle(),
            style: const TextStyle(
              color: plum,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Tap to see your full week',
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          iconColor: berry,
          collapsedIconColor: plum,
          children: List.generate(weeklyPlan.length, (index) {
            final video = weeklyPlan[index];
            final isLast = index == weeklyPlan.length - 1;
            final accent = getAccentColor(video);

            return Column(
              children: [
                InkWell(
                  onTap: () => openVideo(video.url),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: accent,
                          foregroundColor: plum,
                          child: Text(
                            days[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: plum,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _miniChip(video.duration),
                                  const SizedBox(width: 6),
                                  _miniChip(video.type),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          color: berry,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    color: blush,
                    thickness: 1,
                    indent: 56,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: rose,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: plum,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: rose,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: plum, size: 17),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: plum,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: plum,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
