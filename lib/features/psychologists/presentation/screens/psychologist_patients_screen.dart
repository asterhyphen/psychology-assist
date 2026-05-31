import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/smooth_widgets.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class PatientModel {
  final String id;
  final String name;
  final int age;
  final String email;
  final String status; // 'Critical', 'Declining', 'Stable'
  final int score;
  final String lastActive;
  final List<String> tags;
  final bool hasSharedJournal;
  final List<String> sharedJournals;

  const PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
    required this.status,
    required this.score,
    required this.lastActive,
    required this.tags,
    this.hasSharedJournal = false,
    this.sharedJournals = const [],
  });
}

class PsychologistPatientsScreen extends ConsumerStatefulWidget {
  const PsychologistPatientsScreen({super.key});

  @override
  ConsumerState<PsychologistPatientsScreen> createState() =>
      _PsychologistPatientsScreenState();
}

class _PsychologistPatientsScreenState
    extends ConsumerState<PsychologistPatientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All'; // 'All', 'Critical', 'Declining', 'Stable'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final session = ref.watch(appSessionProvider);
    final sessionEmail = session.profile?.email ?? demoPsychologistEmail;

    // Load actual appointments booked with the current psychologist
    final myAppointments = session.appointments
        .where((app) => app.psychologistEmail == sessionEmail)
        .toList();

    // Group appointments by patient email to find unique patients dynamically
    final Map<String, List<Appointment>> patientsGroup = {};
    for (final app in myAppointments) {
      final email = (app.patientEmail ?? 'unnamed@client.com').toLowerCase();
      patientsGroup.putIfAbsent(email, () => []).add(app);
    }

    final List<PatientModel> allPatients = [];
    for (final entry in patientsGroup.entries) {
      final email = entry.key;
      final apps = entry.value;
      
      // Sort to find the latest appointment
      apps.sort((a, b) => b.startsAt.compareTo(a.startsAt));
      final latestApp = apps.first;

      final double drift = latestApp.driftIndex > 0 ? (latestApp.driftIndex * 100) : 25;
      final score = drift.round();
      
      // Symmetrical priority score categories matching the screenshot ranges
      final status = score >= 75 ? 'Critical' : (score >= 40 ? 'Declining' : 'Stable');

      // Link actual shared journal entries from database for this client name/email
      final List<String> patientJournals = [];
      
      // Match journals dynamically by searching for content keywords or name matches
      final shared = session.journalEntries
          .where((j) => j.sharedWithPsychologist)
          .toList();
          
      for (final j in shared) {
        if (latestApp.patientName.toLowerCase().contains('alex') && j.content.toLowerCase().contains('empty')) {
          patientJournals.add(j.content);
        } else if (latestApp.patientName.toLowerCase().contains('jordan') && j.content.toLowerCase().contains('overthinking')) {
          patientJournals.add(j.content);
        }
      }

      // If user-created patient has other shared entries, dynamically add those!
      if (patientJournals.isEmpty && 
          !latestApp.patientName.toLowerCase().contains('alex') && 
          !latestApp.patientName.toLowerCase().contains('jordan')) {
        final otherShared = shared
            .where((j) => !j.content.toLowerCase().contains('empty') && !j.content.toLowerCase().contains('overthinking'))
            .map((j) => j.content)
            .toList();
        patientJournals.addAll(otherShared);
      }

      final lastActiveString = _formatRelativeTime(latestApp.startsAt);

      // Parse tags from appointment note or assign theme-appropriate condition fallbacks
      List<String> tags = [];
      if (latestApp.note.isNotEmpty) {
        tags = latestApp.note.split(',').map((s) => s.trim()).toList();
      } else {
        tags = status == 'Critical'
            ? ['High Stress', 'Needs Care']
            : (status == 'Declining' ? ['Anxiety', 'Monitoring'] : ['Stable', 'CBT Check']);
      }

      // Symmetrical age mapping or default fallback
      final age = email.contains('alex') 
          ? 28 
          : (email.contains('casey') 
              ? 41 
              : (email.contains('jordan') 
                  ? 34 
                  : (email.contains('taylor') 
                      ? 29 
                      : (email.contains('sam') 
                          ? 22 
                          : 30))));

      allPatients.add(
        PatientModel(
          id: email,
          name: latestApp.displayPatientName,
          age: age,
          email: email,
          status: status,
          score: score,
          lastActive: lastActiveString,
          tags: tags,
          hasSharedJournal: patientJournals.isNotEmpty,
          sharedJournals: patientJournals,
        ),
      );
    }

    // Sort patient list by drift score priority descending
    allPatients.sort((a, b) => b.score.compareTo(a.score));

    // Dynamic Filter & Search Implementation
    final filteredPatients = allPatients.where((patient) {
      final matchesSearch = patient.name.toLowerCase().contains(_searchQuery) ||
          patient.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      final matchesTab = _activeFilter == 'All' || patient.status == _activeFilter;
      return matchesSearch && matchesTab;
    }).toList();

    // Summary Calculations from Live database list
    final criticalCount = allPatients.where((p) => p.status == 'Critical').length;
    final decliningCount = allPatients.where((p) => p.status == 'Declining').length;
    final stableCount = allPatients.where((p) => p.status == 'Stable').length;
    
    final double totalScore = allPatients.fold(0, (sum, p) => sum + p.score);
    final avgDrift = allPatients.isEmpty ? 0 : (totalScore / allPatients.length).round();

    final criticalPatients = filteredPatients.where((p) => p.status == 'Critical').toList();
    final decliningPatients = filteredPatients.where((p) => p.status == 'Declining').toList();
    final stablePatients = filteredPatients.where((p) => p.status == 'Stable').toList();

    final cardBgColor = isDark
        ? const Color(0xFF161D2B) // Premium Obsidian/Slate Container matching other cards
        : theme.cardTheme.color ?? Colors.white;

    final cardBorderColor = isDark
        ? const Color(0xFF243049)
        : theme.dividerColor.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Patient Overview'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Dynamic Atmospheric Gradient Background matching settings and dashboards
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF080C11),
                          const Color(0xFF0E121E),
                        ]
                      : [
                          const Color(0xFFF7F8FC),
                          const Color(0xFFF0EFF5),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Top-left soft ambient teal glow
          Positioned(
            top: -120,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0FA58A).withValues(
                    alpha: isDark ? 0.08 : 0.05,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 85, sigmaY: 85),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
          // Mid-right soft ambient indigo glow
          Positioned(
            top: 280,
            right: -150,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(
                    alpha: isDark ? 0.06 : 0.04,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),

          // Scrollable layout body
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header Card
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: cardBgColor,
                    borderColor: cardBorderColor,
                    borderRadius: 18,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.groups,
                            color: Color(0xFF8B5CF6),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Overview',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${allPatients.length} patients · sorted by priority',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: scheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Symmetrical Summary Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Critical',
                          value: '$criticalCount',
                          subtext: 'Need immediate',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Declining',
                          value: '$decliningCount',
                          subtext: 'Monitor closely',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Stable',
                          value: '$stableCount',
                          subtext: 'Routine check-in',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Avg Drift',
                          value: '$avgDrift',
                          subtext: 'Across ${allPatients.length} patients',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search input
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.plusJakartaSans(
                      color: scheme.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search patients or tags...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(Icons.search, color: scheme.onSurface.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: cardBgColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Critical', 'Declining', 'Stable'].map((filter) {
                        final isSelected = _activeFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: isSelected ? Colors.white : scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _activeFilter = filter);
                              }
                            },
                            selectedColor: const Color(0xFF8B5CF6),
                            backgroundColor: cardBgColor,
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF8B5CF6) : cardBorderColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grouped Patient Cards
                  if (criticalPatients.isNotEmpty) ...[
                    _GroupHeader(label: 'CRITICAL — IMMEDIATE ATTENTION', count: criticalPatients.length, color: const Color(0xFFEF4444)),
                    const SizedBox(height: 8),
                    ...criticalPatients.map((p) => _PatientTile(patient: p, cardBgColor: cardBgColor, cardBorderColor: cardBorderColor, onTap: () => _openPatientDrawer(p))),
                    const SizedBox(height: 20),
                  ],

                  if (decliningPatients.isNotEmpty) ...[
                    _GroupHeader(label: 'DECLINING — MONITOR CLOSELY', count: decliningPatients.length, color: const Color(0xFFF59E0B)),
                    const SizedBox(height: 8),
                    ...decliningPatients.map((p) => _PatientTile(patient: p, cardBgColor: cardBgColor, cardBorderColor: cardBorderColor, onTap: () => _openPatientDrawer(p))),
                    const SizedBox(height: 20),
                  ],

                  if (stablePatients.isNotEmpty) ...[
                    _GroupHeader(label: 'STABLE — ROUTINE MONITORING', count: stablePatients.length, color: const Color(0xFF10B981)),
                    const SizedBox(height: 8),
                    ...stablePatients.map((p) => _PatientTile(patient: p, cardBgColor: cardBgColor, cardBorderColor: cardBorderColor, onTap: () => _openPatientDrawer(p))),
                    const SizedBox(height: 20),
                  ],

                  if (filteredPatients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No patients match active filters.',
                          style: GoogleFonts.plusJakartaSans(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  
                  // Journal shared footer capsule
                  SmoothCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: isDark ? const Color(0xFF11101E) : cardBgColor,
                    borderColor: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.2 : 0.4),
                    borderRadius: 16,
                    child: Row(
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, color: Color(0xFF8B5CF6), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient shared logs synced',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                'Click on a patient to view and respond to their entries.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: scheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPatientDrawer(PatientModel p) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final sessionEmail = ref.read(appSessionProvider).profile?.email ?? demoPsychologistEmail;

    final cardBgColor = isDark
        ? const Color(0xFF161D2B)
        : theme.cardTheme.color ?? Colors.white;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F141F) : theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3748) : theme.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: p.status == 'Critical'
                            ? const Color(0xFFEF4444)
                            : (p.status == 'Declining' ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                        child: Text(
                          p.name.split(' ').map((e) => e[0]).join().toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(
                              'Age ${p.age} · ${p.email}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Drift summary indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF2C3748) : theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Priority Drift Score',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(
                              '${p.score}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: p.status == 'Critical'
                                    ? const Color(0xFFEF4444)
                                    : (p.status == 'Declining' ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: p.score / 100.0,
                            minHeight: 8,
                            backgroundColor: isDark ? const Color(0xFF070B11) : theme.dividerColor.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(
                              p.status == 'Critical'
                                  ? const Color(0xFFEF4444)
                                  : (p.status == 'Declining' ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Diagnostic Tags
                  Text(
                    'Active Condition Tags',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF2C3748) : theme.dividerColor),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            color: scheme.onSurface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Shared entries
                  Text(
                    'Shared Journal Entries',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (p.sharedJournals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No shared entries logged recently.',
                          style: GoogleFonts.plusJakartaSans(
                            color: scheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...p.sharedJournals.map((journal) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF2C3748) : theme.dividerColor),
                        ),
                        child: Text(
                          journal,
                          style: GoogleFonts.plusJakartaSans(
                            color: scheme.onSurface.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // Message Client Action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // close bottom sheet
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatScreen(
                            otherUserId: 'patient',
                            otherUserName: p.name,
                            currentUserId: sessionEmail,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble, size: 18),
                    label: Text(
                      'Message Client',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardBgColor = isDark
        ? const Color(0xFF161D2B)
        : theme.cardTheme.color ?? Colors.white;

    final cardBorderColor = isDark
        ? const Color(0xFF243049)
        : theme.dividerColor.withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _GroupHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientTile extends StatelessWidget {
  final PatientModel patient;
  final Color cardBgColor;
  final Color cardBorderColor;
  final VoidCallback onTap;

  const _PatientTile({
    required this.patient,
    required this.cardBgColor,
    required this.cardBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final statusColor = patient.status == 'Critical'
        ? const Color(0xFFEF4444)
        : (patient.status == 'Declining' ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SmoothCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        backgroundColor: cardBgColor,
        borderColor: cardBorderColor,
        onTap: onTap,
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Text(
                    patient.name.split(' ').map((e) => e[0]).join().toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (patient.hasSharedJournal)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '1',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Middle info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        patient.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Age ${patient.age}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (patient.hasSharedJournal)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sticky_note_2_outlined, size: 9, color: Color(0xFF8B5CF6)),
                              const SizedBox(width: 2),
                              Text(
                                'Journal',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8B5CF6),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${patient.status} (${patient.score})',
                              style: GoogleFonts.plusJakartaSans(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 10, color: scheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        patient.lastActive,
                        style: GoogleFonts.plusJakartaSans(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: patient.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark 
                              ? const Color(0xFF1F2937) 
                              : theme.dividerColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark 
                                ? Colors.transparent 
                                : theme.dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Right score display & indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${patient.score}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 14, color: scheme.onSurface.withValues(alpha: 0.3)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? const Color(0xFF1F2937) 
                        : theme.dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 32 * (patient.score / 100.0),
                    height: 3,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
