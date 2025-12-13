import '../models/user.dart';
import '../models/daily_word.dart';
import '../models/qt_log.dart';
import '../models/prayer_request.dart';

const String currentDate = '2024-12-09';

const User currentUser = User(
  id: 'u1',
  name: '지민',
  avatarUrl: 'https://picsum.photos/id/64/200/200',
);

const DailyWord todaysWord = DailyWord(
  date: currentDate,
  reference: '시편 23:1-3',
  scripture: '여호와는 나의 목자시니 내게 부족함이 없으리로다.\n그가 나를 푸른 풀밭에 누이시며 쉴 만한 물 가로 인도하시는도다.\n내 영혼을 소생시키시고 자기 이름을 위하여 의의 길로 인도하시는도다.',
  pastorNote: '선한 목자이신 주님께서는 우리를 가장 좋은 길로 인도하십니다. 때로는 그 길이 굽이돌아가는 것처럼 보일지라도, 목자의 음성을 신뢰하며 나아갈 때 우리는 참된 쉼과 회복을 경험하게 됩니다. 오늘 하루, 내 뜻이 아닌 목자의 인도를 구하는 하루가 되길 소망합니다.',
);

List<QTLog> initialQtLogs = [
  QTLog(
    id: 'q1',
    date: '2024-12-05',
    title: '주님만이 나의 힘',
    content: '힘든 상황 속에서도 주님을 의지해야 함을 깨달았다.',
    application: '자기 전에 감사 기도 하기',
    prayer: '주님 함께 해주세요.',
    isPublic: true,
  ),
  QTLog(
    id: 'q2',
    date: '2024-12-07',
    title: '감사하는 마음',
    content: '작은 것에도 감사할 줄 아는 마음을 주셨다.',
    application: '가족에게 사랑한다고 말하기',
    prayer: '사랑이 넘치는 사람이 되게 하소서.',
    isPublic: true,
  ),
  QTLog(
    id: 'q3',
    date: '2024-12-08',
    title: '거룩한 부담감',
    content: '공동체를 섬기는 것에 대한 마음을 주셨다.',
    application: '이번 주 청소 봉사 신청하기',
    prayer: '섬김의 기쁨을 알게 하소서.',
    isPublic: false,
  ),
];

List<PrayerRequest> initialPrayerRequests = [
  PrayerRequest(
    id: 'p1',
    userId: 'u2',
    userName: '김철수',
    userAvatar: 'https://picsum.photos/id/91/200/200',
    content: '이번 주 중요한 면접이 있습니다. 떨지 않고 준비한 대로 잘 말할 수 있도록, 하나님이 주시는 평안함이 함께 하기를 기도 부탁드립니다.',
    createdAt: DateTime(2024, 12, 9, 8, 30),
    amenCount: 12,
    isAmenedByMe: false,
    type: 'INTERCESSORY',
  ),
  PrayerRequest(
    id: 'p2',
    userId: 'u3',
    userName: '이영희',
    userAvatar: 'https://picsum.photos/id/177/200/200',
    content: '어머니의 건강 검진 결과가 나오는 날입니다. 좋은 결과가 있기를, 어떤 결과든 주님을 신뢰하며 나아갈 수 있기를 기도해주세요.',
    createdAt: DateTime(2024, 12, 9, 7, 15),
    amenCount: 24,
    isAmenedByMe: true,
    type: 'INTERCESSORY',
  ),
];
