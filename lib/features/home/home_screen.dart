import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/mock_data.dart';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';
import 'avenger_logos.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';
  late final List<CulturePost> _feedPosts;
  final Map<String, TextEditingController> _commentControllers = {};
  
  // Daily Pulse state
  int? _selectedPulseOption;
  late final Map<int, int> _pulseVotes;
  bool _hasVotedPulse = false;

  // Streak state
  int _streakDays = 5;

  @override
  void initState() {
    super.initState();
    _feedPosts = StorageService.getCulturePosts();
    _selectedPulseOption = StorageService.getSelectedPulseOption();
    _pulseVotes = StorageService.getPulseVotes();
    _hasVotedPulse = StorageService.hasVotedPulse();
    _streakDays = StorageService.getStreakDays();
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addComment(String postId, String content) {
    if (content.trim().isEmpty) return;
    
    setState(() {
      final postIndex = _feedPosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _feedPosts[postIndex];
        final newComments = List<String>.from(post.comments)
          ..add('${MockData.currentUser.fullName}: $content');
        
        _feedPosts[postIndex] = CulturePost(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          type: post.type,
          content: post.content,
          mediaAsset: post.mediaAsset,
          isAnonymous: post.isAnonymous,
          likes: post.likes,
          commentsCount: newComments.length,
          comments: newComments,
          timestamp: post.timestamp,
        );
        StorageService.saveCulturePosts(_feedPosts);
      }
      _commentControllers[postId]?.clear();
    });
  }

  void _likePost(String postId) {
    setState(() {
      final postIndex = _feedPosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _feedPosts[postIndex];
        _feedPosts[postIndex] = CulturePost(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          type: post.type,
          content: post.content,
          mediaAsset: post.mediaAsset,
          isAnonymous: post.isAnonymous,
          likes: post.likes + 1,
          commentsCount: post.commentsCount,
          comments: post.comments,
          timestamp: post.timestamp,
        );
        StorageService.saveCulturePosts(_feedPosts);
      }
    });
  }

  void _votePulse(int optionIndex) {
    setState(() {
      _selectedPulseOption = optionIndex;
      _pulseVotes[optionIndex] = (_pulseVotes[optionIndex] ?? 0) + 1;
      _hasVotedPulse = true;
      StorageService.saveSelectedPulseOption(_selectedPulseOption);
      StorageService.savePulseVotes(_pulseVotes);
      StorageService.saveHasVotedPulse(_hasVotedPulse);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final filteredPosts = _selectedCategory == 'all'
        ? _feedPosts
        : _feedPosts.where((p) => p.type.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'S.NIDHI Culture Feed',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unified company-wide value alignment stream',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Active Streak Widget
                        Card(
                          color: SannidhiTheme.teal.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt, color: Colors.orange, size: 28),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$_streakDays Day Streak',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const Text('Gratitude Moments', style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'S.NIDHI Culture Feed',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unified company-wide value alignment stream',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Active Streak Widget
                        Card(
                          color: SannidhiTheme.teal.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, color: Colors.orange, size: 28),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$_streakDays Day Streak',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const Text('Gratitude Moments', style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Feed List
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'all',
                              'gratitude',
                              'pioneering',
                              'entrepreneurial',
                              'growth',
                              'inclusive',
                              'excellence'
                            ].map((category) {
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    category[0].toUpperCase() + category.substring(1),
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    }
                                  },
                                  selectedColor: SannidhiTheme.teal.withOpacity(0.2),
                                  checkmarkColor: SannidhiTheme.teal,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Feed posts
                        if (filteredPosts.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.layers_clear, size: 48, color: SannidhiTheme.textMutedDark),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No posts in this category yet.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...filteredPosts.map((post) {
                            if (!_commentControllers.containsKey(post.id)) {
                              _commentControllers[post.id] = TextEditingController();
                            }
                            final isPostAnon = post.isAnonymous;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author Header
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: isPostAnon ? SannidhiTheme.teal : Colors.transparent,
                                          backgroundImage: isPostAnon
                                              ? null
                                              : NetworkImage(post.authorAvatar),
                                          child: isPostAnon
                                              ? const Icon(Icons.shield, color: Colors.white, size: 20)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isPostAnon ? 'Anonymous Hero (Pitch Corner)' : post.authorName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                              Text(
                                                DateFormat('MMM d, yyyy • h:mm a').format(post.timestamp),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Category Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: SannidhiTheme.teal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: SannidhiTheme.teal.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            post.type.toUpperCase(),
                                            style: const TextStyle(
                                              color: SannidhiTheme.teal,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Post Content
                                    Text(
                                      post.content,
                                      style: const TextStyle(fontSize: 14, height: 1.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: AvengerLogo(
                                        valueType: post.type,
                                        size: 140,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Like and Comment Actions
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _likePost(post.id),
                                          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
                                          label: Text('${post.likes} Likes', style: const TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.comment_rounded, color: SannidhiTheme.teal, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${post.commentsCount} Comments',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    // Comments list
                                    if (post.comments.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      ...post.comments.map((comment) {
                                        final parts = comment.split(': ');
                                        final commenter = parts[0];
                                        final commentText = parts.sublist(1).join(': ');
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '$commenter: ',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                TextSpan(text: commentText),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    const SizedBox(height: 12),
                                    // Add Comment Field
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _commentControllers[post.id],
                                            decoration: InputDecoration(
                                              hintText: 'Write a comment...',
                                              hintStyle: const TextStyle(fontSize: 13),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  color: isDark ? SannidhiTheme.darkBorder : SannidhiTheme.lightBorder,
                                                ),
                                              ),
                                            ),
                                            style: const TextStyle(fontSize: 13),
                                            onSubmitted: (value) => _addComment(post.id, value),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () => _addComment(post.id, _commentControllers[post.id]!.text),
                                          icon: const Icon(Icons.send, color: SannidhiTheme.teal, size: 20),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Right Sidebar: Daily Pulse & Streaks Details
                  if (MediaQuery.of(context).size.width > 1100)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // Daily Pulse Poll
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.query_stats_rounded, color: SannidhiTheme.teal),
                                      SizedBox(width: 8),
                                      Text(
                                        'Daily Pulse',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'How aligned do you feel with SANNIDHI\'s mission today?',
                                    style: TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),
                                  ...['Fully aligned & energetic', 'Aligned but busy', 'Struggling with issues', 'Disconnected'].asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final text = entry.value;
                                    
                                    if (_hasVotedPulse) {
                                      // Show results
                                      final totalVotes = _pulseVotes.values.fold(0, (sum, val) => sum + val);
                                      final votes = _pulseVotes[index] ?? 0;
                                      final percent = totalVotes > 0 ? (votes / totalVotes * 100).round() : 0;
                                      final isSelected = _selectedPulseOption == index;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    text,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                Text('$percent%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: percent / 100,
                                              backgroundColor: isDark ? SannidhiTheme.darkBorder : SannidhiTheme.lightBorder,
                                              color: isSelected ? SannidhiTheme.teal : SannidhiTheme.teal.withOpacity(0.4),
                                              minHeight: 6,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Show voting buttons
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: OutlinedButton(
                                          onPressed: () => _votePulse(index),
                                          style: OutlinedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Value Streaks Guide
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.emoji_events_outlined, color: Colors.amber),
                                      SizedBox(width: 8),
                                      Text(
                                        'Value Streaks',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Align your activities with company culture by posting updates regularly.',
                                    style: TextStyle(fontSize: 12, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),
                                  const Row(
                                    children: [
                                      Icon(Icons.circle, color: SannidhiTheme.teal, size: 8),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Gratitude (Moments shared)',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                                    child: Text('Post appreciation to teammates.', style: TextStyle(fontSize: 11)),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(Icons.circle, color: SannidhiTheme.iceBlue, size: 8),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Pioneering (Wall of Fame)',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                                    child: Text('Recognize breakthrough ideas.', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
