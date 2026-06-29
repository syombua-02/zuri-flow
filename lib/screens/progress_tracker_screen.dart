 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
 State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  final FirestoreService _firestore = FirestoreService();

  final TextEditingController weightController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController hipsController = TextEditingController();
  final TextEditingController bustController = TextEditingController();
  final TextEditingController thighController = TextEditingController();
  final TextEditingController armController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isSaving = false;
  bool isLoadingHistory = true;
  DateTime? _checkInDate;

  List<Map<String, dynamic>> progressEntries = [];

  // -------------------- Zuri Theme --------------------
  static const Color blush = Color(0xFFFFF5F7);
  static const Color rose = Color(0xFFFAD7E0);
  static const Color deepRose = Color(0xFFE88AAE);
  static const Color berry = Color(0xFFB85C7A);
  static const Color plum = Color(0xFF6D435A);
  static const Color cream = Color(0xFFFFFBFC);
  static const Color mint = Color(0xFFDDF5E3);
  static const Color lavender = Color(0xFFF0E7FF);

  @override
  void initState() {
    super.initState();
    _loadProgressHistory(showLoader: true);
  }

  @override
  void dispose() {
    weightController.dispose();
    waistController.dispose();
    hipsController.dispose();
    bustController.dispose();
    thighController.dispose();
    armController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ====================== DATA ======================

  Future<void> _loadProgressHistory({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() => isLoadingHistory = true);
    }

    try {
      final entries = await _firestore.getProgressEntries();
      if (!mounted) return;

      setState(() {
        progressEntries = entries;
        isLoadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoadingHistory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load progress history: $e')),
      );
    }
  }

  Future<void> _saveProgress() async {
    if (weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least your weight')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await _firestore.saveProgressEntry(
        weight: weightController.text.trim(),
        waist: waistController.text.trim(),
        hips: hipsController.text.trim(),
        bust: bustController.text.trim(),
        thigh: thighController.text.trim(),
        arm: armController.text.trim(),
        notes: notesController.text.trim(),
        date: _checkInDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress saved successfully')),
      );

      _clearForm();
      await _loadProgressHistory();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save progress: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
          'This progress check-in will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: deepRose,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.deleteProgressEntry(entryId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress entry deleted')),
      );

      await _loadProgressHistory();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete entry: $e')),
      );
    }
  }

  Future<void> _editEntry(Map<String, dynamic> entry) async {
    final weightCtrl = TextEditingController(
      text: (entry['weight'] ?? '').toString(),
    );
    final waistCtrl = TextEditingController(
      text: (entry['waist'] ?? '').toString(),
    );
    final hipsCtrl = TextEditingController(
      text: (entry['hips'] ?? '').toString(),
    );
    final bustCtrl = TextEditingController(
      text: (entry['bust'] ?? '').toString(),
    );
    final thighCtrl = TextEditingController(
      text: (entry['thigh'] ?? '').toString(),
    );
    final armCtrl = TextEditingController(
      text: (entry['arm'] ?? '').toString(),
    );
    final notesCtrl = TextEditingController(
      text: (entry['notes'] ?? '').toString(),
    );

    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        bool isSavingEdit = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: rose,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Edit Check-In',
                      style: TextStyle(
                        color: plum,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(weightCtrl, 'Weight (kg)'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(waistCtrl, 'Waist (in)')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTextField(hipsCtrl, 'Hips (in)')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(bustCtrl, 'Bust/Chest (in)')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTextField(thighCtrl, 'Thigh (in)')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(armCtrl, 'Arm (in)'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      notesCtrl,
                      'Notes',
                      maxLines: 3,
                      isNumber: false,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: berry),
                              foregroundColor: berry,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSavingEdit
                                ? null
                                : () async {
                                    if (weightCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Weight is required for a check-in',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setSheetState(() => isSavingEdit = true);
                                    try {
                                      await _firestore.updateProgressEntry(
                                        entryId: entry['id'],
                                        weight: weightCtrl.text.trim(),
                                        waist: waistCtrl.text.trim(),
                                        hips: hipsCtrl.text.trim(),
                                        bust: bustCtrl.text.trim(),
                                        thigh: thighCtrl.text.trim(),
                                        arm: armCtrl.text.trim(),
                                        notes: notesCtrl.text.trim(),
                                      );
                                      if (!sheetContext.mounted) return;
                                      Navigator.pop(sheetContext, true);
                                    } catch (e) {
                                      if (!ctx.mounted) return;
                                      setSheetState(() => isSavingEdit = false);
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to update entry: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: berry,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isSavingEdit
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (updated == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress entry updated')),
      );
      await _loadProgressHistory();
    }

    weightCtrl.dispose();
    waistCtrl.dispose();
    hipsCtrl.dispose();
    bustCtrl.dispose();
    thighCtrl.dispose();
    armCtrl.dispose();
    notesCtrl.dispose();
  }

  void _clearForm() {
    weightController.clear();
    waistController.clear();
    hipsController.clear();
    bustController.clear();
    thighController.clear();
    armController.clear();
    notesController.clear();
    setState(() => _checkInDate = null);
  }

  // ====================== HELPERS ======================

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString().trim()) ?? 0;
  }

  bool _hasValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isNotEmpty && double.tryParse(text) != null;
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) return timestamp.toDate();
      return null;
    } catch (_) {
      return null;
    }
  }

  int _countImprovedMeasurements(
    Map<String, dynamic> latest,
    Map<String, dynamic> previous,
  ) {
    int improved = 0;

    const keys = ['weight', 'waist', 'hips', 'bust', 'thigh', 'arm'];

    for (final key in keys) {
      if (_hasValue(latest[key]) && _hasValue(previous[key])) {
        final latestValue = _toDouble(latest[key]);
        final previousValue = _toDouble(previous[key]);

        if (latestValue < previousValue) {
          improved++;
        }
      }
    }

    return improved;
  }

  String _buildTrendSummary() {
    if (progressEntries.length < 2) {
      return 'Once you have at least 2 check-ins, Zuri will compare your measurements and show what’s changing over time.';
    }

    final latest = progressEntries[0];
    final previous = progressEntries[1];

    List<String> changes = [];

    if (_hasValue(latest['weight']) && _hasValue(previous['weight'])) {
      final diff = _toDouble(latest['weight']) - _toDouble(previous['weight']);
      if (diff < 0) {
        changes.add('Weight ↓ ${diff.abs().toStringAsFixed(1)} kg');
      } else if (diff > 0) {
        changes.add('Weight ↑ ${diff.abs().toStringAsFixed(1)} kg');
      }
    }

    if (_hasValue(latest['waist']) && _hasValue(previous['waist'])) {
      final diff = _toDouble(latest['waist']) - _toDouble(previous['waist']);
      if (diff < 0) {
        changes.add('Waist ↓ ${diff.abs().toStringAsFixed(1)} in');
      } else if (diff > 0) {
        changes.add('Waist ↑ ${diff.abs().toStringAsFixed(1)} in');
      }
    }

    if (_hasValue(latest['hips']) && _hasValue(previous['hips'])) {
      final diff = _toDouble(latest['hips']) - _toDouble(previous['hips']);
      if (diff < 0) {
        changes.add('Hips ↓ ${diff.abs().toStringAsFixed(1)} in');
      } else if (diff > 0) {
        changes.add('Hips ↑ ${diff.abs().toStringAsFixed(1)} in');
      }
    }

    if (changes.isEmpty) {
      return 'Not enough comparable measurement data yet — keep logging consistently so Zuri can spot clearer trends.';
    }

    return changes.join('  •  ');
  }

  String getProgressInsight() {
    if (progressEntries.length < 2) {
      return 'Add at least 2 check-ins for Zuri to start comparing your weight, measurements, and notes more accurately.';
    }

    final latest = progressEntries[0];
    final previous = progressEntries[1];

    final improvedCount = _countImprovedMeasurements(latest, previous);
    final latestNotes = (latest['notes'] ?? '').toString().toLowerCase();

    bool weightStable = false;
    bool waistStable = false;

    if (_hasValue(latest['weight']) && _hasValue(previous['weight'])) {
      weightStable =
          _toDouble(latest['weight']) == _toDouble(previous['weight']);
    }

    if (_hasValue(latest['waist']) && _hasValue(previous['waist'])) {
      waistStable = _toDouble(latest['waist']) == _toDouble(previous['waist']);
    }

    if (improvedCount >= 3) {
      return 'You’re making strong visible progress across multiple measurements. Keep your current routine, stay hydrated, and stay consistent with your workouts.';
    }

    if (latestNotes.contains('bloated') ||
        latestNotes.contains('bloating') ||
        latestNotes.contains('tired') ||
        latestNotes.contains('low energy')) {
      return 'Your latest notes suggest recovery may need more attention. Focus on hydration, sleep, gentle movement, and balanced meals this week.';
    }

    if (weightStable && waistStable) {
      return 'Your numbers are fairly steady right now. Stay consistent for another week, then consider tightening meal consistency or increasing activity slightly.';
    }

    if (improvedCount >= 1) {
      return 'You’re moving in the right direction. Even if every number hasn’t changed yet, some progress is showing — keep going and stay consistent.';
    }

    return 'Progress looks mixed, which is completely normal. Focus on consistency this week: workouts, sleep, hydration, and realistic nutrition habits.';
  }

  // ====================== UI ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blush,
      appBar: AppBar(
        backgroundColor: blush,
        elevation: 0,
        title: const Text(
          'Progress Tracker',
          style: TextStyle(color: plum, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: plum),
      ),
      body: RefreshIndicator(
        color: berry,
        onRefresh: () => _loadProgressHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 18),

              _buildSectionTitle('Add New Progress Check-In'),
              const SizedBox(height: 10),
              _buildFormCard(),
              const SizedBox(height: 20),

              _buildSectionTitle('Progress Trend'),
              const SizedBox(height: 10),
              _buildTrendCard(),
              const SizedBox(height: 20),

              _buildSectionTitle('Zuri Insight'),
              const SizedBox(height: 10),
              _buildInsightCard(),
              const SizedBox(height: 20),

              _buildSectionTitle('Progress History'),
              const SizedBox(height: 10),

              if (isLoadingHistory)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: berry),
                  ),
                )
              else if (progressEntries.isEmpty)
                _buildEmptyHistoryCard()
              else
                Column(
                  children: progressEntries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildHistoryCard(entry),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepRose, berry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Track your glow-up ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Log your measurements and notes, then let Zuri Flow compare your check-ins and suggest what to keep doing or adjust.',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
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
          _buildTextField(weightController, 'Weight (kg)'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _buildTextField(waistController, 'Waist (in)')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(hipsController, 'Hips (in)')),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTextField(bustController, 'Bust/Chest (in)'),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(thighController, 'Thigh (in)')),
            ],
          ),
          const SizedBox(height: 12),

          _buildTextField(armController, 'Arm (in)'),
          const SizedBox(height: 12),

          _buildTextField(
            notesController,
            'Notes (energy, bloating, strength, clothes fit, etc.)',
            maxLines: 4,
            isNumber: false,
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _checkInDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: berry,
                      onPrimary: Colors.white,
                      surface: cream,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _checkInDate = picked);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: blush,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: berry, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _checkInDate == null
                        ? 'Log for today (tap to change date)'
                        : 'Date: ${DateFormat('dd MMM yyyy').format(_checkInDate!)}',
                    style: TextStyle(
                      color: _checkInDate == null ? Colors.black54 : plum,
                      fontWeight: _checkInDate == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _saveProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepRose,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded),
              label: Text(
                isSaving ? 'Saving...' : 'Save Progress Check-In',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lavender,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.show_chart_rounded, color: plum, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _buildTrendSummary(),
              style: const TextStyle(
                color: plum,
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: plum, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              getProgressInsight(),
              style: const TextStyle(
                color: plum,
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'No progress entries yet. Save your first check-in to start tracking your Zuri Flow journey.',
        style: TextStyle(color: plum, fontSize: 15, height: 1.6),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final date = _parseTimestamp(entry['createdAt']);
    final formattedDate = date != null
        ? DateFormat('dd MMM yyyy').format(date)
        : 'Unknown date';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: plum,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if ((entry['id'] ?? '').toString().isNotEmpty) ...[
                IconButton(
                  onPressed: () => _editEntry(entry),
                  icon: const Icon(Icons.edit_rounded, color: plum),
                  tooltip: 'Edit entry',
                ),
                IconButton(
                  onPressed: () => _deleteEntry(entry['id']),
                  icon: const Icon(Icons.delete_outline_rounded, color: berry),
                  tooltip: 'Delete entry',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatChip('Weight', _displayValue(entry['weight'], 'kg')),
              _buildStatChip('Waist', _displayValue(entry['waist'], 'in')),
              _buildStatChip('Hips', _displayValue(entry['hips'], 'in')),
              _buildStatChip('Bust', _displayValue(entry['bust'], 'in')),
              _buildStatChip('Thigh', _displayValue(entry['thigh'], 'in')),
              _buildStatChip('Arm', _displayValue(entry['arm'], 'in')),
            ],
          ),

          if ((entry['notes'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Notes: ${entry['notes']}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _displayValue(dynamic value, String unit) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '-';
    return '$text $unit';
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isNumber = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.multiline,
      textCapitalization: isNumber
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: plum),
        filled: true,
        fillColor: blush,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
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
}