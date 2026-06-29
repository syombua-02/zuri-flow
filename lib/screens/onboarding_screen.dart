import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  /// True when this screen was opened from "Edit Profile" on an existing
  /// account, rather than during first-time signup. When true, saving
  /// just pops back to the previous screen instead of navigating to
  /// [MainShell] — the user is already inside the app shell.
  final bool isEditing;

  const OnboardingScreen({super.key, this.isEditing = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final FirestoreService _firestore = FirestoreService();
  final PageController _pageController = PageController();

  static const int totalSteps = 4;
  int currentStep = 0;

  String selectedGoal = 'Weight Loss';
  String selectedActivity = 'Beginner';
  String selectedMovementPreference = 'Pilates + Yoga';
  String selectedWorkoutIntensity = 'Moderate';
  String selectedFocusArea = 'Full Body';
  String selectedEquipment = 'None';
  String selectedWorkoutDuration = '20-30 min';
  String selectedWorkoutDays = '4 days/week';
  String selectedLimitations = 'None';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  bool isLoading = false;
  bool isLoadingExistingData = false;

  static const Color blush = Color(0xFFFFF5F7);
  static const Color rose = Color(0xFFFAD7E0);
  static const Color berry = Color(0xFFB85C7A);
  static const Color plum = Color(0xFF6D435A);
  static const Color cream = Color(0xFFFFFBFC);

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _prefillFromExistingProfile();
    }
  }

  Future<void> _prefillFromExistingProfile() async {
    setState(() => isLoadingExistingData = true);

    try {
      final data = await _firestore.getUserData();
      if (!mounted || data == null) return;

      setState(() {
        selectedGoal = _safeOption(data['goal'], goalOptions, selectedGoal);
        selectedActivity =
            _safeOption(data['activity'], activityOptions, selectedActivity);
        selectedMovementPreference = _safeOption(
          data['movementPreference'],
          movementOptions,
          selectedMovementPreference,
        );
        selectedWorkoutIntensity = _safeOption(
          data['workoutIntensity'],
          intensityOptions,
          selectedWorkoutIntensity,
        );
        selectedFocusArea = _safeOption(
          data['focusArea'],
          focusAreaOptions,
          selectedFocusArea,
        );
        selectedEquipment = _safeOption(
          data['equipment'],
          equipmentOptions,
          selectedEquipment,
        );
        selectedWorkoutDuration = _safeOption(
          data['workoutDuration'],
          durationOptions,
          selectedWorkoutDuration,
        );
        selectedWorkoutDays = _safeOption(
          data['workoutDays'],
          workoutDaysOptions,
          selectedWorkoutDays,
        );
        selectedLimitations = _safeOption(
          data['limitations'],
          limitationsOptions,
          selectedLimitations,
        );

        nameController.text = (data['name'] ?? '').toString();
        weightController.text = (data['weight'] ?? '').toString();
        heightController.text = (data['height'] ?? '').toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load your existing profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoadingExistingData = false);
      }
    }
  }

  /// Returns [value] if it's a non-empty string found in [options],
  /// otherwise falls back to [fallback]. Guards against
  /// DropdownButtonFormField throwing when a saved value (e.g. from an
  /// older app version) no longer matches the current options list.
  String _safeOption(
    dynamic value,
    List<String> options,
    String fallback,
  ) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return fallback;
    return options.contains(text) ? text : fallback;
  }

  static const List<String> goalOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Toning',
    'Healthy Living',
  ];
  static const List<String> activityOptions = ['Beginner', 'Moderate', 'Active'];
  static const List<String> movementOptions = [
    'Pilates',
    'Yoga',
    'Pilates + Yoga',
    'Stretching + Mobility',
  ];
  static const List<String> intensityOptions = [
    'Gentle',
    'Moderate',
    'Challenging',
  ];
  static const List<String> focusAreaOptions = [
    'Full Body',
    'Core',
    'Glutes',
    'Arms',
    'Flexibility',
    'Stress Relief',
    'Posture',
  ];
  static const List<String> equipmentOptions = [
    'None',
    'Mat',
    'Resistance Bands',
    'Light Dumbbells',
    'Bands + Dumbbells',
  ];
  static const List<String> durationOptions = [
    '10-15 min',
    '20-30 min',
    '30-45 min',
    '45-60 min',
  ];
  static const List<String> workoutDaysOptions = [
    '2 days/week',
    '3 days/week',
    '4 days/week',
    '5 days/week',
    '6 days/week',
  ];
  static const List<String> limitationsOptions = [
    'None',
    'Knee Pain',
    'Back Pain',
    'Low Energy',
    'Bloating',
    'Beginner Confidence',
  ];

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    heightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Step 2 (index 1) is the only step with free-text required fields.
  /// Every other step always has a valid default selected, so there's
  /// nothing to block on.
  bool _validateCurrentStep() {
    if (currentStep == 1) {
      if (weightController.text.trim().isEmpty ||
          heightController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter weight and height')),
        );
        return false;
      }
    }
    return true;
  }

  void _goToNextStep() {
    if (!_validateCurrentStep()) return;

    if (currentStep == totalSteps - 1) {
      _submit();
      return;
    }

    setState(() => currentStep += 1);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _goToPreviousStep() {
    if (currentStep == 0) {
      Navigator.maybePop(context);
      return;
    }

    setState(() => currentStep -= 1);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submit() async {
    setState(() => isLoading = true);

    try {
      await _firestore.saveUserData(
        name: nameController.text.trim(),
        goal: selectedGoal,
        weight: weightController.text.trim(),
        height: heightController.text.trim(),
        activity: selectedActivity,
        movementPreference: selectedMovementPreference,
        workoutIntensity: selectedWorkoutIntensity,
        focusArea: selectedFocusArea,
        equipment: selectedEquipment,
        workoutDuration: selectedWorkoutDuration,
        workoutDays: selectedWorkoutDays,
        limitations: selectedLimitations,
      );

      if (!mounted) return;

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: plum),
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: options
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: plum),
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Shared wrapper for each step's content: a heading, a short
  /// supporting line, and the fields for that step.
  Widget _buildStepBody({
    required String heading,
    required String subheading,
    required List<Widget> fields,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              heading,
              style: const TextStyle(
                color: plum,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subheading,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < fields.length; i++) ...[
              fields[i],
              if (i != fields.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return _buildStepBody(
      heading: 'What are you working toward?',
      subheading:
          'This shapes the workouts and meals Zuri recommends for you.',
      fields: [
        _buildTextField(
          controller: nameController,
          label: 'Your first name',
          textCapitalization: TextCapitalization.words,
        ),
        _buildDropdown(
          label: 'Your Goal',
          value: selectedGoal,
          options: goalOptions,
          onChanged: (value) => setState(() => selectedGoal = value),
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return _buildStepBody(
      heading: 'A little about your body',
      subheading:
          'Used to personalize calorie and movement guidance — never shown publicly.',
      fields: [
        _buildTextField(controller: weightController, label: 'Weight (kg)', isNumber: true),
        _buildTextField(controller: heightController, label: "Height (e.g. 5'1\")", isNumber: false),
        _buildDropdown(
          label: 'Activity Level',
          value: selectedActivity,
          options: activityOptions,
          onChanged: (value) => setState(() => selectedActivity = value),
        ),
      ],
    );
  }

  Widget _buildStepThree() {
    return _buildStepBody(
      heading: 'How do you like to train?',
      subheading: 'Zuri will match videos and routines to these preferences.',
      fields: [
        _buildDropdown(
          label: 'Main Focus Area',
          value: selectedFocusArea,
          options: focusAreaOptions,
          onChanged: (value) => setState(() => selectedFocusArea = value),
        ),
        _buildDropdown(
          label: 'Preferred Movement Style',
          value: selectedMovementPreference,
          options: movementOptions,
          onChanged: (value) =>
              setState(() => selectedMovementPreference = value),
        ),
        _buildDropdown(
          label: 'Workout Intensity',
          value: selectedWorkoutIntensity,
          options: intensityOptions,
          onChanged: (value) =>
              setState(() => selectedWorkoutIntensity = value),
        ),
        _buildDropdown(
          label: 'Equipment Available',
          value: selectedEquipment,
          options: equipmentOptions,
          onChanged: (value) => setState(() => selectedEquipment = value),
        ),
        _buildDropdown(
          label: 'Preferred Workout Duration',
          value: selectedWorkoutDuration,
          options: durationOptions,
          onChanged: (value) =>
              setState(() => selectedWorkoutDuration = value),
        ),
        _buildDropdown(
          label: 'Workout Days Per Week',
          value: selectedWorkoutDays,
          options: workoutDaysOptions,
          onChanged: (value) => setState(() => selectedWorkoutDays = value),
        ),
      ],
    );
  }

  Widget _buildStepFour() {
    return _buildStepBody(
      heading: 'Anything we should know?',
      subheading:
          'Zuri will keep your recommendations gentler around this if needed.',
      fields: [
        _buildDropdown(
          label: 'Any Limitation?',
          value: selectedLimitations,
          options: limitationsOptions,
          onChanged: (value) => setState(() => selectedLimitations = value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingExistingData) {
      return Scaffold(
        backgroundColor: blush,
        appBar: AppBar(
          backgroundColor: blush,
          elevation: 0,
          title: const Text(
            'Edit your profile',
            style: TextStyle(color: plum, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: plum),
        ),
        body: const Center(child: CircularProgressIndicator(color: berry)),
      );
    }

    final isLastStep = currentStep == totalSteps - 1;

    return Scaffold(
      backgroundColor: blush,
      appBar: AppBar(
        backgroundColor: blush,
        elevation: 0,
        leading: IconButton(
          onPressed: isLoading ? null : _goToPreviousStep,
          icon: const Icon(Icons.arrow_back_rounded, color: plum),
        ),
        title: Text(
          widget.isEditing ? 'Edit your profile' : 'Tell us about you',
          style: const TextStyle(color: plum, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${currentStep + 1} of $totalSteps',
                        style: const TextStyle(
                          color: plum,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        widget.isEditing
                            ? 'Update your details ✨'
                            : 'Build your personal plan ✨',
                        style: const TextStyle(
                          color: berry,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / totalSteps,
                      minHeight: 6,
                      backgroundColor: rose,
                      valueColor: const AlwaysStoppedAnimation<Color>(berry),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepOne(),
                  _buildStepTwo(),
                  _buildStepThree(),
                  _buildStepFour(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _goToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: berry,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLastStep
                              ? (widget.isEditing
                                  ? 'Save changes'
                                  : 'Build my plan')
                              : 'Continue',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
