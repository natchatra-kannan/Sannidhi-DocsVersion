import 'package:flutter/material.dart';
import '../../core/theme.dart';

class VeeduScreen extends StatefulWidget {
  const VeeduScreen({super.key});

  @override
  State<VeeduScreen> createState() => _VeeduScreenState();
}

class _VeeduScreenState extends State<VeeduScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Prep Checklist State
  final List<Map<String, dynamic>> _prepItems = [
    {'title': 'Complete Supabase Integration onboarding', 'checked': true},
    {'title': 'Set up local Flutter environment', 'checked': true},
    {'title': 'Update profile details & upload photo', 'checked': false},
    {'title': 'Nominate a team member for Awards 25\'', 'checked': false},
    {'title': 'Read company culture values handbook', 'checked': false},
  ];

  // Business Class Mock Files
  final List<Map<String, String>> _businessFiles = [
    {'title': 'Vite Web Deployment Guide', 'format': 'PDF', 'size': '2.4 MB'},
    {'title': 'Supabase RLS Best Practices', 'format': 'PDF', 'size': '1.8 MB'},
    {'title': 'State Management with Riverpod 2.0', 'format': 'DOCX', 'size': '920 KB'},
    {'title': 'UI Polish & Custom Painters in Flutter', 'format': 'PDF', 'size': '5.2 MB'},
  ];

  // Videos Mock Data
  final List<Map<String, String>> _videos = [
    {'title': 'Soorarai Pottru - Launch Session', 'duration': '45:20', 'views': '230 views'},
    {'title': 'Values Engine Architecture Sync', 'duration': '28:15', 'views': '142 views'},
    {'title': 'Product Roadmap & Vision 2026', 'duration': '1:12:05', 'views': '310 views'},
    {'title': 'Inclusion & Excellence Keynote', 'duration': '34:40', 'views': '98 views'},
  ];

  // Itinerary Mock Data
  final List<Map<String, dynamic>> _itineraryDays = [
    {
      'day': 'Day 1: Foundation',
      'events': [
        {'time': '09:00 AM', 'title': 'Welcome & Opening Address', 'desc': 'Auditorium A • Keynote speech by lead founders.'},
        {'time': '11:00 AM', 'title': 'Culture Feed Deep Dive', 'desc': 'Conference Room B • Understanding gratitude & pioneering values.'},
        {'time': '01:00 PM', 'title': 'Networking Lunch', 'desc': 'Main Cafeteria • Interact with other teams.'},
        {'time': '02:30 PM', 'title': 'Supabase Backend Sync', 'desc': 'Lab 3 • Reviewing schemas and Row Level Security.'},
      ]
    },
    {
      'day': 'Day 2: Execution',
      'events': [
        {'time': '09:30 AM', 'title': 'Sprint Kickoff & Core Workouts', 'desc': 'Team Zones • Start building frontend widgets.'},
        {'time': '12:00 PM', 'title': 'Awards 25\' Kickoff', 'desc': 'Main Stage • Unveiling the 11 Tamil value categories.'},
        {'time': '03:00 PM', 'title': 'Interactive Pitch Corner', 'desc': 'Nexus Room • Live voting on anonymous submissions.'},
      ]
    },
    {
      'day': 'Day 3: Launch & Excellence',
      'events': [
        {'time': '10:00 AM', 'title': 'Meeting Room System Demo', 'desc': 'Helipad Boardroom • Showcase of booking and conflict checks.'},
        {'time': '02:00 PM', 'title': 'Closing Awards Ceremony', 'desc': 'Grand Ballroom • Announcement of Sei, Yayum, Ulavu award winners.'},
        {'time': '06:00 PM', 'title': 'Celebration Dinner & Social', 'desc': 'Stark Terrace • Evening dinner and entertainment.'},
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '△வீ (Veedu) Hub',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Company prep tools, courses, itinerary, and reference videos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: SannidhiTheme.teal,
          labelColor: SannidhiTheme.teal,
          unselectedLabelColor: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
          tabs: const [
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Prep'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Business Class'),
            Tab(icon: Icon(Icons.video_library_outlined), text: 'Videos'),
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Itinerary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Prep checklist View
          _buildPrepView(theme, isDark),
          
          // Business Class View
          _buildBusinessClassView(theme, isDark),

          // Videos View
          _buildVideosView(theme, isDark),

          // Itinerary View
          _buildItineraryView(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildPrepView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, color: SannidhiTheme.teal, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Preparation Checklist',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Complete these foundational setup steps before launching new features or modules.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _prepItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _prepItems[index];
                      return CheckboxListTile(
                        value: item['checked'] as bool,
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: item['checked'] as bool
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        activeColor: SannidhiTheme.teal,
                        onChanged: (val) {
                          setState(() {
                            _prepItems[index]['checked'] = val;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessClassView(ThemeData theme, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemCount: _businessFiles.length,
      itemBuilder: (context, index) {
        final file = _businessFiles[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SannidhiTheme.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        file['format']!,
                        style: const TextStyle(
                          color: SannidhiTheme.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.article_outlined,
                      color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                    ),
                  ],
                ),
                Text(
                  file['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      file['size']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 14),
                      label: const Text('Download', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosView(ThemeData theme, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.3,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: isDark ? Colors.black26 : Colors.black12,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 48,
                      color: SannidhiTheme.teal,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          video['duration']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                          ),
                        ),
                        Text(
                          video['views']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItineraryView(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: _itineraryDays.length,
      itemBuilder: (context, dayIndex) {
        final dayData = _itineraryDays[dayIndex];
        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayData['day'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SannidhiTheme.teal,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (dayData['events'] as List).length,
                  itemBuilder: (context, eventIndex) {
                    final event = (dayData['events'] as List)[eventIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              event['time'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: SannidhiTheme.iceBlue,
                              ),
                            ),
                          ),
                          const Column(
                            children: [
                              Icon(Icons.radio_button_checked, size: 16, color: SannidhiTheme.teal),
                              SizedBox(height: 24),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
