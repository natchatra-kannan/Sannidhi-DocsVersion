import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/mock_data.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  final List<AwardNomination> _nominations = List.from(MockData.initialNominations);
  
  // Form fields
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedNominee;
  final _reasonController = TextEditingController();

  // Autosave simulation state
  Timer? _autosaveTimer;
  bool _isAutosaving = false;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _reasonController.dispose();
    super.dispose();
  }

  // Auto-save logic: debounced trigger after 1.5 seconds of no typing
  void _onReasonChanged() {
    if (_reasonController.text.trim().isEmpty) return;
    
    _autosaveTimer?.cancel();
    setState(() {
      _isAutosaving = true;
    });

    _autosaveTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isAutosaving = false;
          _lastSavedAt = DateTime.now();
        });
      }
    });
  }

  void _submitNomination() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null || _selectedNominee == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both Category and Nominee.')),
        );
        return;
      }

      final newNomination = AwardNomination(
        id: 'nom-${DateTime.now().millisecondsSinceEpoch}',
        categoryName: _selectedCategory!,
        nomineeName: _selectedNominee!,
        reason: _reasonController.text,
        nominatorName: MockData.currentUser.fullName,
        timestamp: DateTime.now(),
      );

      setState(() {
        _nominations.insert(0, newNomination);
        _selectedCategory = null;
        _selectedNominee = null;
        _reasonController.clear();
        _lastSavedAt = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomination submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Awards 25\' Nominations',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Recognize high-impact contributions matching core values',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Nomination Form
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.emoji_events_rounded, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text(
                                    'Nominate a Peer',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              // Autosave indicator
                              if (_isAutosaving)
                                const Text(
                                  'Saving draft...',
                                  style: TextStyle(fontSize: 11, color: SannidhiTheme.teal, fontStyle: FontStyle.italic),
                                )
                              else if (_lastSavedAt != null)
                                Text(
                                  'Draft saved at ${DateFormat('hh:mm:ss a').format(_lastSavedAt!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Category selector
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Tamil Value Category',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: MockData.awardCategories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.name,
                                child: Text('${cat.name} - ${cat.description}', overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCategory = val);
                              _onReasonChanged(); // trigger save
                            },
                            validator: (val) => val == null ? 'Please select category' : null,
                          ),
                          const SizedBox(height: 16),

                          // Nominee selector
                          DropdownButtonFormField<String>(
                            value: _selectedNominee,
                            decoration: InputDecoration(
                              labelText: 'Nominee Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: MockData.allProfiles
                                .where((p) => p.id != MockData.currentUserId) // cannot nominate self
                                .map((p) {
                              return DropdownMenuItem<String>(
                                value: p.fullName,
                                child: Text(p.fullName),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedNominee = val);
                              _onReasonChanged(); // trigger save
                            },
                            validator: (val) => val == null ? 'Please select nominee' : null,
                          ),
                          const SizedBox(height: 16),

                          // Reason input
                          TextFormField(
                            controller: _reasonController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              labelText: 'Reason for Nomination',
                              hintText: 'Describe their impact. Please specify concrete examples (minimum 10 words).',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter the nomination reason';
                              }
                              final wordCount = val.trim().split(RegExp(r'\s+')).length;
                              if (wordCount < 10) {
                                return 'Please be more descriptive (at least 10 words required). Current: $wordCount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _submitNomination,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SannidhiTheme.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Submit Nomination', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Submitted Nominations Report
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Nominations Log',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _nominations.length,
                      itemBuilder: (context, index) {
                        final nom = _nominations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nominee: ${nom.nomineeName}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: SannidhiTheme.teal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        nom.categoryName.toUpperCase(),
                                        style: const TextStyle(
                                          color: SannidhiTheme.teal,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nom.reason,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: isDark ? SannidhiTheme.textLight : SannidhiTheme.textDark,
                                  ),
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'By ${nom.nominatorName}',
                                      style: const TextStyle(fontSize: 10, color: SannidhiTheme.textMutedDark),
                                    ),
                                    Text(
                                      DateFormat('MMM d, yyyy').format(nom.timestamp),
                                      style: const TextStyle(fontSize: 10, color: SannidhiTheme.textMutedDark),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
