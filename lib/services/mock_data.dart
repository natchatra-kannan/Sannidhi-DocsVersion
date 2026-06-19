
class AttendanceRecord {
  final String id;
  final String userName;
  final DateTime timestamp;
  final String mode; // 'Work From Home' or 'Present in Office'
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isLate;

  AttendanceRecord({
    required this.id,
    required this.userName,
    required this.timestamp,
    required this.mode,
    this.latitude,
    this.longitude,
    required this.isVerified,
    required this.isLate,
  });
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String avatarUrl;
  final int coinsReceived;
  final int coinsSent;
  final int coinsDeducted;
  final int balance;
  final List<String> achievements;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.avatarUrl,
    required this.coinsReceived,
    required this.coinsSent,
    required this.coinsDeducted,
    required this.balance,
    required this.achievements,
  });
}

class Team {
  final String id;
  final String name;
  final String description;
  final String leadName;
  final List<String> memberIds;
  final List<String> alumniIds;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.leadName,
    required this.memberIds,
    required this.alumniIds,
  });
}

class CulturePost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String type; // gratitude, pioneering, entrepreneurial, growth, inclusive, excellence
  final String content;
  final String? mediaAsset; // local asset path
  final bool isAnonymous;
  final int likes;
  final int commentsCount;
  final List<String> comments;
  final DateTime timestamp;

  CulturePost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.type,
    required this.content,
    this.mediaAsset,
    required this.isAnonymous,
    required this.likes,
    required this.commentsCount,
    required this.comments,
    required this.timestamp,
  });
}

class MeetingRoom {
  final String id;
  final String name;
  final int capacity;
  final String location;

  MeetingRoom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.location,
  });
}

class MeetingBooking {
  final String id;
  final String roomId;
  final String bookedBy;
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  MeetingBooking({
    required this.id,
    required this.roomId,
    required this.bookedBy,
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}

class AwardCategory {
  final String name;
  final String description;

  AwardCategory({required this.name, required this.description});
}

class AwardNomination {
  final String id;
  final String categoryName;
  final String nomineeName;
  final String reason;
  final String nominatorName;
  final DateTime timestamp;

  AwardNomination({
    required this.id,
    required this.categoryName,
    required this.nomineeName,
    required this.reason,
    required this.nominatorName,
    required this.timestamp,
  });
}

class MockData {
  static final String currentUserId = 'user-tony';
  
  static final UserProfile currentUser = UserProfile(
    id: currentUserId,
    email: 'tony.stark@sannidhi.com',
    fullName: 'Tony Stark',
    role: 'Lead Architect (EdgeOps)',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120',
    coinsReceived: 1420,
    coinsSent: 850,
    coinsDeducted: 50,
    balance: 520,
    achievements: [
      'Pioneer Star 2026',
      'Innovation Master - Pitch Corner',
      'Excellence Core Contributor',
      '5-Day Gratitude Streak'
    ],
  );

  static final List<UserProfile> allProfiles = [
    currentUser,
    UserProfile(
      id: 'user-cap',
      email: 'steve.rogers@sannidhi.com',
      fullName: 'Steve Rogers',
      role: 'Team Lead (Aspire)',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120',
      coinsReceived: 2100,
      coinsSent: 1200,
      coinsDeducted: 0,
      balance: 900,
      achievements: ['Valiant Mentor', 'Inclusion Champion', 'Excellence Shield'],
    ),
    UserProfile(
      id: 'user-nat',
      email: 'natasha.romanoff@sannidhi.com',
      fullName: 'Natasha Romanoff',
      role: 'Operations Lead (SISU)',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120',
      coinsReceived: 1850,
      coinsSent: 1500,
      coinsDeducted: 10,
      balance: 340,
      achievements: ['Hidden Gem Finder', 'Resolution Specialist'],
    ),
    UserProfile(
      id: 'user-thor',
      email: 'thor.odinson@sannidhi.com',
      fullName: 'Thor Odinson',
      role: 'Senior Developer (Dolabs)',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=120',
      coinsReceived: 1200,
      coinsSent: 600,
      coinsDeducted: 200,
      balance: 400,
      achievements: ['Hammer of Excellence', 'Lightning Coder'],
    ),
    UserProfile(
      id: 'user-bruce',
      email: 'bruce.banner@sannidhi.com',
      fullName: 'Bruce Banner',
      role: 'Data Scientist (Externship)',
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=120',
      coinsReceived: 950,
      coinsSent: 400,
      coinsDeducted: 0,
      balance: 550,
      achievements: ['Smart Growth Award', 'Quiet Contributor'],
    ),
    UserProfile(
      id: 'user-peter',
      email: 'peter.parker@sannidhi.com',
      fullName: 'Peter Parker',
      role: 'Frontend Intern (Aspire)',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=120',
      coinsReceived: 800,
      coinsSent: 200,
      coinsDeducted: 0,
      balance: 600,
      achievements: ['Junior Pioneer', 'Web Wizard'],
    ),
  ];

  static final List<Team> teams = [
    Team(
      id: 'team-aspire',
      name: 'Aspire',
      description: 'Focuses on talent acceleration, foundational training, and core career development paths.',
      leadName: 'Steve Rogers',
      memberIds: ['user-cap', 'user-peter'],
      alumniIds: ['user-thor'],
    ),
    Team(
      id: 'team-dolabs',
      name: 'Dolabs',
      description: 'The experimental technology lab. Incubates next-gen tooling and rapid prototyping environments.',
      leadName: 'Thor Odinson',
      memberIds: ['user-thor'],
      alumniIds: ['user-tony'],
    ),
    Team(
      id: 'team-externship',
      name: 'Externship',
      description: 'Connects academic and outside research talents with core product goals.',
      leadName: 'Bruce Banner',
      memberIds: ['user-bruce'],
      alumniIds: [],
    ),
    Team(
      id: 'team-sisu',
      name: 'SISU',
      description: 'Operational resilience, program management, and cultural coordination group.',
      leadName: 'Natasha Romanoff',
      memberIds: ['user-nat'],
      alumniIds: ['user-cap'],
    ),
    Team(
      id: 'team-edgeops',
      name: 'EdgeOps',
      description: 'DevOps, continuous deployment, cloud infrastructure, and low latency architectures.',
      leadName: 'Tony Stark',
      memberIds: ['user-tony'],
      alumniIds: ['user-bruce'],
    ),
  ];

  static final List<CulturePost> culturePosts = [
    CulturePost(
      id: 'post-1',
      authorId: 'user-cap',
      authorName: 'Steve Rogers',
      authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120',
      type: 'pioneering',
      content: 'Incredible work by the EdgeOps team in stabilizing the pipeline. Lead Architect Tony Stark showed true pioneering spirit in refactoring the legacy build systems. The response time dropped by 45%!',
      mediaAsset: 'assets/images/pioneering_avengers.png',
      isAnonymous: false,
      likes: 42,
      commentsCount: 2,
      comments: [
        'Tony Stark: Just another Friday afternoon. Glad we got it sorted!',
        'Bruce Banner: Phenomenal reduction in execution overhead, Tony.'
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CulturePost(
      id: 'post-2',
      authorId: 'user-peter',
      authorName: 'Peter Parker',
      authorAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=120',
      type: 'gratitude',
      content: 'So thankful to Natasha Romanoff for taking the time to guide me through the security compliance checklist this morning. Truly inclusive guidance that helped me understand the why, not just the what.',
      mediaAsset: null,
      isAnonymous: false,
      likes: 18,
      commentsCount: 1,
      comments: [
        'Natasha Romanoff: Always happy to assist. You picked it up very fast!'
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    CulturePost(
      id: 'post-3',
      authorId: 'anonymous',
      authorName: 'Anonymous Hero',
      authorAvatar: '',
      type: 'entrepreneurial',
      content: 'Idea: What if we build a Slack bot that automatically detects when someone has a continuous gratitude streak and rewards them with culture coins? Let\'s fight this out in the next Pitch Corner!',
      mediaAsset: 'assets/images/entrepreneurial_avengers.png',
      isAnonymous: true,
      likes: 35,
      commentsCount: 3,
      comments: [
        'Tony Stark: Love this. I can build the backend in a weekend.',
        'Steve Rogers: Excellent value alignment.',
        'Thor Odinson: Aye! A worthy endeavor!'
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CulturePost(
      id: 'post-4',
      authorId: 'user-bruce',
      authorName: 'Bruce Banner',
      authorAvatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=120',
      type: 'growth',
      content: 'Just finished our first cross-functional study circle on Advanced Quantum Algorithms. The team showed amazing holistic growth. Knowledge belongs to everyone.',
      mediaAsset: 'assets/images/growth_avengers.png',
      isAnonymous: false,
      likes: 29,
      commentsCount: 0,
      comments: [],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CulturePost(
      id: 'post-5',
      authorId: 'user-nat',
      authorName: 'Natasha Romanoff',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120',
      type: 'inclusive',
      content: 'Shoutout to the quiet superstars in EdgeOps working behind the scenes. Your diligence is a hidden gem that makes all our deployments flawless.',
      mediaAsset: 'assets/images/inclusive_avengers.png',
      isAnonymous: false,
      likes: 56,
      commentsCount: 1,
      comments: [
        'Tony Stark: We do appreciate the shoutout!'
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final List<MeetingRoom> meetingRooms = [
    MeetingRoom(id: 'room-helipad', name: 'Stark Helipad View', capacity: 12, location: 'Floor 93, Sector A'),
    MeetingRoom(id: 'room-lab', name: 'Banner Laboratory Room', capacity: 6, location: 'Floor 42, Sector B'),
    MeetingRoom(id: 'room-nexus', name: 'Holographic Nexus', capacity: 20, location: 'Floor 100, Sector Alpha'),
    MeetingRoom(id: 'room-archive', name: 'S.H.I.E.L.D. Secure Vault', capacity: 4, location: 'Sub-level 4'),
  ];

  static final List<MeetingBooking> initialBookings = [
    MeetingBooking(
      id: 'booking-1',
      roomId: 'room-helipad',
      bookedBy: 'Steve Rogers',
      title: 'Aspire Weekly Alignment',
      startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
      endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 30),
    ),
    MeetingBooking(
      id: 'booking-2',
      roomId: 'room-lab',
      bookedBy: 'Bruce Banner',
      title: 'Gamma Radiation Analytics Sync',
      startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0),
      endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15, 30),
    ),
  ];

  static final List<AwardCategory> awardCategories = [
    AwardCategory(name: 'Sei', description: 'Action-oriented leadership and direct execution impact.'),
    AwardCategory(name: 'Yayum', description: 'Universal harmony, collaborative design, and styling excellence.'),
    AwardCategory(name: 'Ulavu', description: 'Deep-dive analytical research, discovery, and systemic improvements.'),
    AwardCategory(name: 'Uppu', description: 'Essential resilience, security audits, and foundational strength.'),
    AwardCategory(name: 'Yaal', description: 'Creative expression, storytelling, UI polish, and aesthetic perfection.'),
    AwardCategory(name: 'Savaal', description: 'Courage under pressure, crisis resolution, and rapid deployment rescue.'),
    AwardCategory(name: 'Sol', description: 'Clear communication, outstanding documentation, and mentorship.'),
    AwardCategory(name: 'Samam', description: 'Fostering equality, inclusive leadership, and community building.'),
    AwardCategory(name: 'Uyir', description: 'Sustainable initiatives, ecological awareness, and team well-being.'),
    AwardCategory(name: 'Saram', description: 'Exemplary values representation and consistent top performance.'),
    AwardCategory(name: 'Uru', description: 'Outstanding architectural design, database design, and framework creation.'),
  ];

  static final List<AwardNomination> initialNominations = [
    AwardNomination(
      id: 'nom-1',
      categoryName: 'Sei',
      nomineeName: 'Tony Stark',
      reason: 'Tony singlehandedly rewrote the deploy pipeline, speeding up releases from once a day to continuous delivery.',
      nominatorName: 'Steve Rogers',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final List<AttendanceRecord> attendanceRecords = [
    AttendanceRecord(
      id: 'att-1',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 1, 9, 30),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-2',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 2, 10, 15),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-3',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 3, 11, 5),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: true,
    ),
    AttendanceRecord(
      id: 'att-4',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 4, 10, 0),
      mode: 'Work From Home',
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-5',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 5, 10, 45),
      mode: 'Work From Home',
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-6',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 8, 9, 15),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-7',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 9, 11, 20),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: true,
    ),
    AttendanceRecord(
      id: 'att-8',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 11, 10, 10),
      mode: 'Work From Home',
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-9',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 12, 10, 25),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-10',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 15, 9, 45),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-11',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 16, 10, 48),
      mode: 'Work From Home',
      isVerified: true,
      isLate: false,
    ),
    AttendanceRecord(
      id: 'att-12',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 17, 12, 15),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: true,
    ),
    AttendanceRecord(
      id: 'att-13',
      userName: 'Tony Stark',
      timestamp: DateTime(2026, 6, 18, 9, 50),
      mode: 'Present in Office',
      latitude: 13.0405,
      longitude: 80.2415,
      isVerified: true,
      isLate: false,
    ),
  ];
}
