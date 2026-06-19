import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_data.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 1. Streak & Pulse
  static int getStreakDays() {
    return _prefs?.getInt('sannidhi_streak_days') ?? 5;
  }

  static Future<void> saveStreakDays(int days) async {
    await _prefs?.setInt('sannidhi_streak_days', days);
  }

  static bool hasVotedPulse() {
    return _prefs?.getBool('sannidhi_has_voted_pulse') ?? false;
  }

  static Future<void> saveHasVotedPulse(bool voted) async {
    await _prefs?.setBool('sannidhi_has_voted_pulse', voted);
  }

  static int? getSelectedPulseOption() {
    final val = _prefs?.getInt('sannidhi_selected_pulse_option');
    return val == -1 ? null : val;
  }

  static Future<void> saveSelectedPulseOption(int? option) async {
    await _prefs?.setInt('sannidhi_selected_pulse_option', option ?? -1);
  }

  static Map<int, int> getPulseVotes() {
    final jsonStr = _prefs?.getString('sannidhi_pulse_votes');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> rawMap = jsonDecode(jsonStr);
        return rawMap.map((key, value) => MapEntry(int.parse(key), value as int));
      } catch (_) {}
    }
    return {0: 14, 1: 32, 2: 8, 3: 3};
  }

  static Future<void> savePulseVotes(Map<int, int> votes) async {
    final rawMap = votes.map((key, value) => MapEntry(key.toString(), value));
    await _prefs?.setString('sannidhi_pulse_votes', jsonEncode(rawMap));
  }

  // 2. Profile Details (Coins balance & Achievements)
  static int getCoinsBalance() {
    return _prefs?.getInt('sannidhi_profile_coins_balance') ?? 520;
  }

  static Future<void> saveCoinsBalance(int balance) async {
    await _prefs?.setInt('sannidhi_profile_coins_balance', balance);
  }

  static List<String> getAchievements() {
    return _prefs?.getStringList('sannidhi_profile_achievements') ?? const [
      'Pioneer Star 2026',
      'Innovation Master - Pitch Corner',
      'Excellence Core Contributor',
      '5-Day Gratitude Streak'
    ];
  }

  static Future<void> saveAchievements(List<String> achievements) async {
    await _prefs?.setStringList('sannidhi_profile_achievements', achievements);
  }

  // 3. Culture Feed Posts
  static List<CulturePost> getCulturePosts() {
    final jsonStr = _prefs?.getString('sannidhi_culture_posts');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => _postFromMap(item)).toList();
      } catch (_) {}
    }
    return List.from(MockData.culturePosts);
  }

  static Future<void> saveCulturePosts(List<CulturePost> posts) async {
    final list = posts.map((post) => _postToMap(post)).toList();
    await _prefs?.setString('sannidhi_culture_posts', jsonEncode(list));
  }

  // 4. Meeting Room Bookings
  static List<MeetingBooking> getBookings() {
    final jsonStr = _prefs?.getString('sannidhi_bookings');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => _bookingFromMap(item)).toList();
      } catch (_) {}
    }
    return List.from(MockData.initialBookings);
  }

  static Future<void> saveBookings(List<MeetingBooking> bookings) async {
    final list = bookings.map((b) => _bookingToMap(b)).toList();
    await _prefs?.setString('sannidhi_bookings', jsonEncode(list));
  }

  // 5. Award Nominations
  static List<AwardNomination> getNominations() {
    final jsonStr = _prefs?.getString('sannidhi_nominations');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => _nominationFromMap(item)).toList();
      } catch (_) {}
    }
    return List.from(MockData.initialNominations);
  }

  static Future<void> saveNominations(List<AwardNomination> nominations) async {
    final list = nominations.map((n) => _nominationToMap(n)).toList();
    await _prefs?.setString('sannidhi_nominations', jsonEncode(list));
  }

  // 6. Attendance Records
  static List<AttendanceRecord> getAttendanceRecords() {
    final jsonStr = _prefs?.getString('sannidhi_attendance_records');
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => _attendanceFromMap(item)).toList();
      } catch (_) {}
    }
    return List.from(MockData.attendanceRecords);
  }

  static Future<void> saveAttendanceRecords(List<AttendanceRecord> records) async {
    final list = records.map((r) => _attendanceToMap(r)).toList();
    await _prefs?.setString('sannidhi_attendance_records', jsonEncode(list));
  }

  // Model Mapper Helpers (To avoid modifying model class constructors if they are used elsewhere)
  static Map<String, dynamic> _postToMap(CulturePost post) => {
        'id': post.id,
        'authorId': post.authorId,
        'authorName': post.authorName,
        'authorAvatar': post.authorAvatar,
        'type': post.type,
        'content': post.content,
        'mediaAsset': post.mediaAsset,
        'isAnonymous': post.isAnonymous,
        'likes': post.likes,
        'commentsCount': post.commentsCount,
        'comments': post.comments,
        'timestamp': post.timestamp.toIso8601String(),
      };

  static CulturePost _postFromMap(Map<String, dynamic> map) => CulturePost(
        id: map['id'] as String,
        authorId: map['authorId'] as String,
        authorName: map['authorName'] as String,
        authorAvatar: map['authorAvatar'] as String,
        type: map['type'] as String,
        content: map['content'] as String,
        mediaAsset: map['mediaAsset'] as String?,
        isAnonymous: map['isAnonymous'] as bool,
        likes: map['likes'] as int,
        commentsCount: map['commentsCount'] as int,
        comments: List<String>.from(map['comments'] ?? []),
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  static Map<String, dynamic> _bookingToMap(MeetingBooking b) => {
        'id': b.id,
        'roomId': b.roomId,
        'bookedBy': b.bookedBy,
        'title': b.title,
        'startTime': b.startTime.toIso8601String(),
        'endTime': b.endTime.toIso8601String(),
      };

  static MeetingBooking _bookingFromMap(Map<String, dynamic> map) => MeetingBooking(
        id: map['id'] as String,
        roomId: map['roomId'] as String,
        bookedBy: map['bookedBy'] as String,
        title: map['title'] as String,
        startTime: DateTime.parse(map['startTime'] as String),
        endTime: DateTime.parse(map['endTime'] as String),
      );

  static Map<String, dynamic> _nominationToMap(AwardNomination n) => {
        'id': n.id,
        'categoryName': n.categoryName,
        'nomineeName': n.nomineeName,
        'reason': n.reason,
        'nominatorName': n.nominatorName,
        'timestamp': n.timestamp.toIso8601String(),
      };

  static AwardNomination _nominationFromMap(Map<String, dynamic> map) => AwardNomination(
        id: map['id'] as String,
        categoryName: map['categoryName'] as String,
        nomineeName: map['nomineeName'] as String,
        reason: map['reason'] as String,
        nominatorName: map['nominatorName'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  static Map<String, dynamic> _attendanceToMap(AttendanceRecord r) => {
        'id': r.id,
        'userName': r.userName,
        'timestamp': r.timestamp.toIso8601String(),
        'mode': r.mode,
        'latitude': r.latitude,
        'longitude': r.longitude,
        'isVerified': r.isVerified,
        'isLate': r.isLate,
      };

  static AttendanceRecord _attendanceFromMap(Map<String, dynamic> map) => AttendanceRecord(
        id: map['id'] as String,
        userName: map['userName'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        mode: map['mode'] as String,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        isVerified: map['isVerified'] as bool,
        isLate: map['isLate'] as bool,
      );
}
