import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'interfaces.dart';
import '../services/mock_data.dart';

// Provide live Supabase instances when useSupabaseProvider is toggled to true
final supabaseAuthRepositoryProvider = Provider<AuthRepository>((ref) => SupabaseAuthRepositoryImpl());
final supabaseDirectoryRepositoryProvider = Provider<DirectoryRepository>((ref) => SupabaseDirectoryRepositoryImpl());
final supabaseCultureRepositoryProvider = Provider<CultureRepository>((ref) => SupabaseCultureRepositoryImpl());
final supabaseBookingRepositoryProvider = Provider<BookingRepository>((ref) => SupabaseBookingRepositoryImpl());
final supabaseNominationRepositoryProvider = Provider<NominationRepository>((ref) => SupabaseNominationRepositoryImpl());

// Overriding swapper logic from interfaces.dart to support Supabase integrations
final liveAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  return useSupabase ? ref.read(supabaseAuthRepositoryProvider) : ref.read(mockAuthRepositoryProvider);
});

final liveDirectoryRepositoryProvider = Provider<DirectoryRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  return useSupabase ? ref.read(supabaseDirectoryRepositoryProvider) : ref.read(mockDirectoryRepositoryProvider);
});

final liveCultureRepositoryProvider = Provider<CultureRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  return useSupabase ? ref.read(supabaseCultureRepositoryProvider) : ref.read(mockCultureRepositoryProvider);
});

final liveBookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  return useSupabase ? ref.read(supabaseBookingRepositoryProvider) : ref.read(mockBookingRepositoryProvider);
});

final liveNominationRepositoryProvider = Provider<NominationRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  return useSupabase ? ref.read(supabaseNominationRepositoryProvider) : ref.read(mockNominationRepositoryProvider);
});


// 1. Live Supabase Auth
class SupabaseAuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<UserProfile?> getCurrentUser() async {
    final sessionUser = _client.auth.currentUser;
    if (sessionUser == null) return null;
    
    // Fetch profile details
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', sessionUser.id)
        .single();
    
    return _mapProfile(data);
  }

  @override
  Future<void> signInWithOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'http://localhost:5000/callback',
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'http://localhost:5000/callback',
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Stream<UserProfile?> authStateChanges() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      try {
        final data = await _client.from('profiles').select().eq('id', user.id).single();
        return _mapProfile(data);
      } catch (e) {
        return null;
      }
    });
  }

  UserProfile _mapProfile(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
      role: data['role'] as String? ?? 'Member',
      avatarUrl: data['avatar_url'] as String? ?? '',
      coinsReceived: data['coins_received'] as int? ?? 0,
      coinsSent: data['coins_sent'] as int? ?? 0,
      coinsDeducted: data['coins_deducted'] as int? ?? 0,
      balance: data['balance'] as int? ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
    );
  }
}

// 2. Live Supabase Employee Directory
class SupabaseDirectoryRepositoryImpl implements DirectoryRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    final List<dynamic> data = await _client.from('profiles').select();
    return data.map((json) => _mapProfile(json)).toList();
  }

  @override
  Future<List<Team>> getTeams() async {
    final List<dynamic> data = await _client.from('teams').select();
    return data.map((json) {
      return Team(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        leadName: 'Team Lead', // Resolve dynamically or map standard
        memberIds: [],
        alumniIds: [],
      );
    }).toList();
  }

  @override
  Future<List<UserProfile>> getTeamMembers(String teamId) async {
    final List<dynamic> data = await _client
        .from('team_members')
        .select('*, profiles(*)')
        .eq('team_id', teamId);
    
    return data
        .map((json) => json['profiles'])
        .where((p) => p != null)
        .map((p) => _mapProfile(p as Map<String, dynamic>))
        .toList();
  }

  UserProfile _mapProfile(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
      role: data['role'] as String? ?? 'Member',
      avatarUrl: data['avatar_url'] as String? ?? '',
      coinsReceived: data['coins_received'] as int? ?? 0,
      coinsSent: data['coins_sent'] as int? ?? 0,
      coinsDeducted: data['coins_deducted'] as int? ?? 0,
      balance: data['balance'] as int? ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
    );
  }
}

// 3. Live Supabase Culture Feed
class SupabaseCultureRepositoryImpl implements CultureRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<CulturePost>> getPosts() async {
    final List<dynamic> data = await _client
        .from('culture_posts')
        .select('*, profiles(*), culture_comments(*, profiles(*))')
        .order('created_at', ascending: false);
    
    return data.map((json) {
      final author = json['profiles'] as Map<String, dynamic>?;
      final commentsList = json['culture_comments'] as List<dynamic>? ?? [];
      final commentsParsed = commentsList.map((c) {
        final commenter = c['profiles'] as Map<String, dynamic>?;
        final name = commenter != null ? commenter['full_name'] as String : 'Member';
        return '$name: ${c['content']}';
      }).toList();

      return CulturePost(
        id: json['id'] as String,
        authorId: json['author_id'] as String? ?? '',
        authorName: author != null ? author['full_name'] as String : 'Sannidhi Hero',
        authorAvatar: author != null ? author['avatar_url'] as String? ?? '' : '',
        type: json['type'] as String,
        content: json['content'] as String,
        mediaAsset: json['media_url'] as String?,
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        likes: json['likes_count'] as int? ?? 0,
        commentsCount: commentsParsed.length,
        comments: commentsParsed,
        timestamp: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<CulturePost> createPost(String content, String type, bool isAnonymous) async {
    final response = await _client.from('culture_posts').insert({
      'author_id': _client.auth.currentUser?.id,
      'type': type,
      'content': content,
      'is_anonymous': isAnonymous,
    }).select('*, profiles(*)').single();

    final author = response['profiles'] as Map<String, dynamic>?;
    return CulturePost(
      id: response['id'] as String,
      authorId: response['author_id'] as String? ?? '',
      authorName: author != null ? author['full_name'] as String : 'Sannidhi Hero',
      authorAvatar: author != null ? author['avatar_url'] as String? ?? '' : '',
      type: response['type'] as String,
      content: response['content'] as String,
      isAnonymous: response['is_anonymous'] as bool? ?? false,
      likes: 0,
      commentsCount: 0,
      comments: [],
      timestamp: DateTime.parse(response['created_at'] as String),
    );
  }

  @override
  Future<void> likePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    // Add reaction
    await _client.from('culture_reactions').insert({
      'post_id': postId,
      'user_id': userId,
    });
    
    // Increment likes count on post
    await _client.rpc('increment_likes_count', params: {'post_id': postId});
  }

  @override
  Future<void> addComment(String postId, String commentText) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('culture_comments').insert({
      'post_id': postId,
      'author_id': userId,
      'content': commentText,
    });
  }
}

// 4. Live Supabase Meeting Booking
class SupabaseBookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<MeetingRoom>> getRooms() async {
    final List<dynamic> data = await _client.from('meeting_rooms').select();
    return data.map((json) {
      return MeetingRoom(
        id: json['id'] as String,
        name: json['name'] as String,
        capacity: json['capacity'] as int,
        location: json['location'] as String,
      );
    }).toList();
  }

  @override
  Future<List<MeetingBooking>> getBookings(String roomId) async {
    final List<dynamic> data = await _client
        .from('meeting_room_bookings')
        .select('*, profiles(*)')
        .eq('room_id', roomId);
    
    return data.map((json) {
      final prof = json['profiles'] as Map<String, dynamic>?;
      return MeetingBooking(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        bookedBy: prof != null ? prof['full_name'] as String : 'Member',
        title: json['title'] as String,
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
      );
    }).toList();
  }

  @override
  Future<MeetingBooking> createBooking(String roomId, String title, DateTime start, DateTime end) async {
    final userId = _client.auth.currentUser?.id;
    final response = await _client.from('meeting_room_bookings').insert({
      'room_id': roomId,
      'booked_by': userId,
      'title': title,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
    }).select('*, profiles(*)').single();

    final prof = response['profiles'] as Map<String, dynamic>?;
    return MeetingBooking(
      id: response['id'] as String,
      roomId: response['room_id'] as String,
      bookedBy: prof != null ? prof['full_name'] as String : 'Member',
      title: response['title'] as String,
      startTime: DateTime.parse(response['start_time'] as String),
      endTime: DateTime.parse(response['end_time'] as String),
    );
  }
}

// 5. Live Supabase Awards Nominations
class SupabaseNominationRepositoryImpl implements NominationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<AwardNomination>> getNominations() async {
    final List<dynamic> data = await _client
        .from('award_nominations')
        .select('*, award_categories(*), profiles!award_nominations_nominee_id_fkey(*), profiles!award_nominations_nominator_id_fkey(*)');
    
    return data.map((json) {
      final category = json['award_categories'] as Map<String, dynamic>?;
      final nominee = json['profiles!award_nominations_nominee_id_fkey'] as Map<String, dynamic>?;
      final nominator = json['profiles!award_nominations_nominator_id_fkey'] as Map<String, dynamic>?;

      return AwardNomination(
        id: json['id'] as String,
        categoryName: category != null ? category['name'] as String : 'Category',
        nomineeName: nominee != null ? nominee['full_name'] as String : 'Nominee',
        reason: json['reason'] as String,
        nominatorName: nominator != null ? nominator['full_name'] as String : 'Nominator',
        timestamp: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> createNomination(String category, String nominee, String reason) async {
    final userId = _client.auth.currentUser?.id;
    
    // Resolve category id and nominee id from names
    final categoryData = await _client.from('award_categories').select('id').eq('name', category).single();
    final nomineeData = await _client.from('profiles').select('id').eq('full_name', nominee).single();

    await _client.from('award_nominations').insert({
      'category_id': categoryData['id'],
      'nominee_id': nomineeData['id'],
      'nominator_id': userId,
      'reason': reason,
    });
  }

  @override
  Future<void> saveDraftNomination(String category, String nominee, String reason) async {
    // Save draft representation
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    // Add logic to save draft or autosave to a draft state table if needed
  }
}
