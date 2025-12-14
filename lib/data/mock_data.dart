import '../models/user.dart';
import '../models/daily_word.dart';
import '../models/qt_log.dart';
import '../models/prayer_request.dart';
import '../models/group.dart';

final String currentDate = DateTime.now().toIso8601String().substring(0, 10);

// Mock Groups
final List<Group> mockGroups = [
  const Group(
    id: 'g1',
    name: '하루만나교회',
    adminId: 'u1',
    isAutoJoin: false,
    adminTitle: '목사님',
    userTitle: '성도님',
  ),
  const Group(
    id: 'g2',
    name: '테스트 목장',
    adminId: 'u99',
    isAutoJoin: true,
  ),
];

const User currentUser = User(
  id: 'u1',
  email: 'jimin@example.com',
  name: '지민',
  avatarUrl: 'https://picsum.photos/id/64/200/200',
  role: UserRole.superAdmin, // Default to SuperAdmin for testing
  groupId: 'g1',
);

final DailyWord todaysWord = DailyWord(
  date: currentDate,
  reference: '시편 23:1-3',
  scripture: '여호와는 나의 목자시니 내게 부족함이 없으리로다.\n그가 나를 푸른 풀밭에 누이시며 쉴 만한 물 가로 인도하시는도다.\n내 영혼을 소생시키시고 자기 이름을 위하여 의의 길로 인도하시는도다.',
  pastorNote: '선한 목자이신 주님께서는 우리를 가장 좋은 길로 인도하십니다. 때로는 그 길이 굽이돌아가는 것처럼 보일지라도, 목자의 음성을 신뢰하며 나아갈 때 우리는 참된 쉼과 회복을 경험하게 됩니다. 오늘 하루, 내 뜻이 아닌 목자의 인도를 구하는 하루가 되길 소망합니다.',
);

// Generate Random Mock Data (100 days back, starting from Yesterday)
List<QTLog> initialQtLogs = List.generate(100, (index) {
  final base = DateTime.parse(currentDate);
  final targetDate = base.subtract(Duration(days: index + 1)); // Start from Yesterday
  final fmtDate = targetDate.toIso8601String().substring(0, 10);
  
  // Random Scenario with reduced 'None' probability to 1/14 (Half of previous 1/7)
  final r = DateTime.now().millisecondsSinceEpoch + index; 
  final scenario = (r % 14); // 0-13 range

  final logs = <QTLog>[];

  if (scenario < 4) { // All (4/14)
    logs.add(QTLog(id: 'd${index}_me', userId: 'u1', date: fmtDate, title: '나의 묵상', content: '...', application: '...', prayer: '...', isPublic: true));
    logs.add(QTLog(id: 'd${index}_other', userId: 'u2', date: fmtDate, title: '이웃 묵상', content: '...', application: '...', prayer: '...', isPublic: true));
  } else if (scenario < 9) { // Me Only (5/14)
    logs.add(QTLog(id: 'd${index}_me', userId: 'u1', date: fmtDate, title: '나의 묵상', content: '...', application: '...', prayer: '...', isPublic: true));
  } else if (scenario < 13) { // Group Only (4/14)
    logs.add(QTLog(id: 'd${index}_other', userId: 'u2', date: fmtDate, title: '이웃 묵상', content: '...', application: '...', prayer: '...', isPublic: true));
  }
  // scenario 13 is None (1/14)
  
  return logs;
}).expand((x) => x).toList();

List<PrayerRequest> initialPrayerRequests = [
  // --- INTERCESSORY (중보기도) ---
  PrayerRequest(
    id: 'p1',
    userId: 'u1', // Me
    userName: '지민',
    userAvatar: 'https://picsum.photos/id/64/200/200',
    content: '새로운 프로젝트를 시작하게 되었습니다. 팀원들과의 화합과 지혜로운 결정을 할 수 있도록 기도 부탁드립니다. 업무 중에도 주님의 향기를 드러내는 사람이 되길 원합니다.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    amenCount: 5,
    isAmenedByMe: false,
    type: 'INTERCESSORY',
  ),
  PrayerRequest(
    id: 'p2',
    userId: 'u2',
    userName: '김철수',
    userAvatar: 'https://picsum.photos/id/91/200/200',
    content: '이번 주 중요한 면접이 있습니다. 떨지 않고 준비한 대로 잘 말할 수 있도록, 하나님이 주시는 평안함이 함께 하기를 기도 부탁드립니다.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    amenCount: 12,
    isAmenedByMe: true,
    type: 'INTERCESSORY',
  ),
  PrayerRequest(
    id: 'p3',
    userId: 'u3',
    userName: '이영희',
    userAvatar: 'https://picsum.photos/id/177/200/200',
    content: '어머니의 건강 검진 결과가 나오는 날입니다. 좋은 결과가 있기를, 어떤 결과든 주님을 신뢰하며 나아갈 수 있기를 기도해주세요. 검사 과정에서도 의료진의 손길을 붙들어 주시고, 가족 모두에게 평안한 마음 허락해 주시기를 간절히 원합니다. 주님의 치유하심을 믿습니다.',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
    amenCount: 24,
    isAmenedByMe: true,
    type: 'INTERCESSORY',
  ),
  PrayerRequest(
    id: 'p4',
    userId: 'u4',
    userName: '박민수',
    userAvatar: 'https://picsum.photos/id/338/200/200',
    content: '진로에 대해 고민이 많습니다. 하나님께서 원하시는 길이 무엇인지 분별할 수 있는 지혜를 주시고, 닫힌 문 앞에서 낙심하지 않고 열린 문을 향해 담대히 나아갈 수 있도록 믿음을 더하여 주세요. 함께 기도해주시면 큰 힘이 될 것 같습니다.',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 10)),
    amenCount: 8,
    isAmenedByMe: false,
    type: 'INTERCESSORY',
  ),

  // --- ONE_ON_ONE (1:1 기도) ---
  PrayerRequest(
    id: 'o1',
    userId: 'u1', // Me
    userName: '지민',
    userAvatar: 'https://picsum.photos/id/64/200/200',
    content: '목사님, 요즘 영적으로 많이 침체되어 있는 것 같습니다. 말씀이 잘 들어오지 않고 기도도 잘 되지 않습니다. 어떻게 해야 이 시기를 잘 이겨낼 수 있을까요? 상담과 기도를 부탁드립니다.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    amenCount: 0,
    isAmenedByMe: false,
    type: 'ONE_ON_ONE',
  ),
  PrayerRequest(
    id: 'o2',
    userId: 'u1', // Me
    userName: '지민',
    userAvatar: 'https://picsum.photos/id/64/200/200',
    content: '가정 내에 작은 불화가 있습니다. 남편과의 대화가 자꾸 어긋나는데, 제가 먼저 낮아지고 섬길 수 있는 마음을 달라고 기도해주셨으면 합니다.',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    amenCount: 1, // Pastor clicked Amen
    isAmenedByMe: true, // 관리자가 아멘한 상태 - 완료된 기도로 분류
    type: 'ONE_ON_ONE',
  ),
];
