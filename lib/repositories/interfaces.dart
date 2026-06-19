import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mock_data.dart';
import '../services/storage_service.dart';

// -------------------------------------------------------------
// REPOSITORY INTERFACES
// -------------------------------------------------------------

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<void> signInWithOtp(String email);
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Stream<UserProfile?> authStateChanges();
}

abstract class DirectoryRepository {
  Future<List<UserProfile>> getAllProfiles();
  Future<List<Team>> getTeams();
  Future<List<UserProfile>> getTeamMembers(String teamId);
}

abstract class CultureRepository {
  Future<List<CulturePost>> getPosts();
  Future<CulturePost> createPost(String content, String type, bool isAnonymous);
  Future<void> likePost(String postId);
  Future<void> addComment(String postId, String commentText);
}

abstract class BookingRepository {
  Future<List<MeetingRoom>> getRooms();
  Future<List<MeetingBooking>> getBookings(String roomId);
  Future<MeetingBooking> createBooking(String roomId, String title, DateTime start, DateTime end);
}

abstract class NominationRepository {
  Future<List<AwardNomination>> getNominations();
  Future<void> createNomination(String category, String nominee, String reason);
  Future<void> saveDraftNomination(String category, String nominee, String reason);
}

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceRecords();
  Future<AttendanceRecord> punchAttendance(String userName, String mode, double? latitude, double? longitude, bool isVerified, bool isLate);
}

// -------------------------------------------------------------
// PROVIDERS (Defaulting to Mock, but swappable)
// -------------------------------------------------------------

final useSupabaseProvider = Provider<bool>((ref) => false); // Set to true to switch to Production Supabase

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  if (useSupabase) {
    throw UnimplementedError('Supabase authentication credentials not configured yet.');
  }
  return ref.read(mockAuthRepositoryProvider);
});

final directoryRepositoryProvider = Provider<DirectoryRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  if (useSupabase) {
    throw UnimplementedError('Supabase database credentials not configured yet.');
  }
  return ref.read(mockDirectoryRepositoryProvider);
});

final cultureRepositoryProvider = Provider<CultureRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  if (useSupabase) {
    throw UnimplementedError('Supabase database credentials not configured yet.');
  }
  return ref.read(mockCultureRepositoryProvider);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  if (useSupabase) {
    throw UnimplementedError('Supabase database credentials not configured yet.');
  }
  return ref.read(mockBookingRepositoryProvider);
});

final nominationRepositoryProvider = Provider<NominationRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseProvider);
  if (useSupabase) {
    throw UnimplementedError('Supabase database credentials not configured yet.');
  }
  return ref.read(mockNominationRepositoryProvider);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return ref.read(mockAttendanceRepositoryProvider);
});

final mockAttendanceRepositoryProvider = Provider<AttendanceRepository>((ref) => MockAttendanceRepositoryImpl());

final attendanceStateProvider = StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return AttendanceNotifier(repo);
});

class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  final AttendanceRepository _repo;
  AttendanceNotifier(this._repo) : super([]) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = await _repo.getAttendanceRecords();
  }

  Future<void> punch(String userName, String mode, double? latitude, double? longitude, bool isVerified, bool isLate) async {
    final record = await _repo.punchAttendance(userName, mode, latitude, longitude, isVerified, isLate);
    state = [record, ...state];
  }
}

// Providers for mock implementation details
final mockAuthRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepositoryImpl());
final mockDirectoryRepositoryProvider = Provider<DirectoryRepository>((ref) => MockDirectoryRepositoryImpl());
final mockCultureRepositoryProvider = Provider<CultureRepository>((ref) => MockCultureRepositoryImpl());
final mockBookingRepositoryProvider = Provider<BookingRepository>((ref) => MockBookingRepositoryImpl());
final mockNominationRepositoryProvider = Provider<NominationRepository>((ref) => MockNominationRepositoryImpl());

// State stream providers for UI bindings
final currentUserStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

// -------------------------------------------------------------
// MOCK IMPLEMENTATIONS
// -------------------------------------------------------------

class MockAuthRepositoryImpl implements AuthRepository {
  final _controller = StateController<UserProfile?>(MockData.currentUser);

  @override
  Future<UserProfile?> getCurrentUser() async => _controller.state;

  @override
  Future<void> signInWithOtp(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    _controller.state = MockData.currentUser;
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _controller.state = MockData.currentUser;
  }

  @override
  Future<void> signOut() async {
    _controller.state = null;
  }

  @override
  Stream<UserProfile?> authStateChanges() => _controller.stream;
}

class MockDirectoryRepositoryImpl implements DirectoryRepository {
  @override
  Future<List<UserProfile>> getAllProfiles() async {
    return MockData.allProfiles;
  }

  @override
  Future<List<Team>> getTeams() async {
    return MockData.teams;
  }

  @override
  Future<List<UserProfile>> getTeamMembers(String teamId) async {
    final team = MockData.teams.firstWhere((t) => t.id == teamId);
    return MockData.allProfiles.where((p) => team.memberIds.contains(p.id)).toList();
  }
}

class MockCultureRepositoryImpl implements CultureRepository {
  final List<CulturePost> _posts = StorageService.getCulturePosts();

  @override
  Future<List<CulturePost>> getPosts() async {
    return _posts;
  }

  @override
  Future<CulturePost> createPost(String content, String type, bool isAnonymous) async {
    final newPost = CulturePost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: MockData.currentUserId,
      authorName: MockData.currentUser.fullName,
      authorAvatar: MockData.currentUser.avatarUrl,
      type: type,
      content: content,
      isAnonymous: isAnonymous,
      likes: 0,
      commentsCount: 0,
      comments: [],
      timestamp: DateTime.now(),
    );
    _posts.insert(0, newPost);
    await StorageService.saveCulturePosts(_posts);
    return newPost;
  }

  @override
  Future<void> likePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = CulturePost(
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
      await StorageService.saveCulturePosts(_posts);
    }
  }

  @override
  Future<void> addComment(String postId, String commentText) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newComments = List<String>.from(post.comments)
        ..add('${MockData.currentUser.fullName}: $commentText');
      _posts[index] = CulturePost(
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
      await StorageService.saveCulturePosts(_posts);
    }
  }
}

class MockBookingRepositoryImpl implements BookingRepository {
  final List<MeetingBooking> _bookings = StorageService.getBookings();

  @override
  Future<List<MeetingRoom>> getRooms() async {
    return MockData.meetingRooms;
  }

  @override
  Future<List<MeetingBooking>> getBookings(String roomId) async {
    return _bookings.where((b) => b.roomId == roomId).toList();
  }

  @override
  Future<MeetingBooking> createBooking(String roomId, String title, DateTime start, DateTime end) async {
    final newBooking = MeetingBooking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      bookedBy: MockData.currentUser.fullName,
      title: title,
      startTime: start,
      endTime: end,
    );
    _bookings.add(newBooking);
    await StorageService.saveBookings(_bookings);
    return newBooking;
  }
}

class MockNominationRepositoryImpl implements NominationRepository {
  final List<AwardNomination> _nominations = StorageService.getNominations();

  @override
  Future<List<AwardNomination>> getNominations() async {
    return _nominations;
  }

  @override
  Future<void> createNomination(String category, String nominee, String reason) async {
    final newNomination = AwardNomination(
      id: 'nom-${DateTime.now().millisecondsSinceEpoch}',
      categoryName: category,
      nomineeName: nominee,
      reason: reason,
      nominatorName: MockData.currentUser.fullName,
      timestamp: DateTime.now(),
    );
    _nominations.insert(0, newNomination);
    await StorageService.saveNominations(_nominations);
  }

  @override
  Future<void> saveDraftNomination(String category, String nominee, String reason) async {
    // Simulated background autosave
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

class MockAttendanceRepositoryImpl implements AttendanceRepository {
  final List<AttendanceRecord> _records = StorageService.getAttendanceRecords();

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    return _records;
  }

  @override
  Future<AttendanceRecord> punchAttendance(String userName, String mode, double? latitude, double? longitude, bool isVerified, bool isLate) async {
    final newRecord = AttendanceRecord(
      id: 'att-${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      timestamp: DateTime.now(),
      mode: mode,
      latitude: latitude,
      longitude: longitude,
      isVerified: isVerified,
      isLate: isLate,
    );
    _records.insert(0, newRecord);
    await StorageService.saveAttendanceRecords(_records);
    return newRecord;
  }
}
