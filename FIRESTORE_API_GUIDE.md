# Firestore API 구조 가이드

이 문서는 HaruManna(하루만나) 애플리케이션에 필요한 Firestore 컬렉션 구조와 문서 스키마를 설명합니다.

## 1. 컬렉션 개요

| 컬렉션 이름 | 설명 | 문서 ID (Document ID) |
| :--- | :--- | :--- |
| `users` | 사용자 프로필 및 인증 데이터 | `userId` (인증 시스템에서 제공) |
| `daily_words` | 매일의 말씀 및 목사님 묵상 포인트 | `YYYY-MM-DD` 문자열 |
| `qt_logs` | 사용자의 개인 묵상 기록 | 자동 생성 ID |
| `prayer_requests` | 중보기도 및 1:1 기도 요청 | 자동 생성 ID |

---

## 2. 상세 스키마 (Detailed Schemas)

### A. 사용자 - Users (`users`)
사용자의 프로필 정보를 저장합니다.

**문서 경로**: `users/{userId}`

**필드 (Fields)**:
| 필드명 | 타입 | 설명 |
| :--- | :--- | :--- |
| `email` | String | 사용자 이메일 주소 |
| `name` | String | 사용자 이름 (표시용) |
| `avatarUrl` | String | 프로필 이미지 URL |
| `createdAt` | Timestamp | 계정 생성일 |

**JSON 예시**:
```json
{
  "email": "user@example.com",
  "name": "지민",
  "avatarUrl": "https://picsum.photos/200",
  "createdAt": 1702166400000
}
```

### B. 오늘의 말씀 - Daily Words (`daily_words`)
관리자/목사님이 제공하는 매일의 말씀 컨텐츠를 저장합니다.

**문서 경로**: `daily_words/{dateString}` (예: `daily_words/2024-12-09`)

**필드 (Fields)**:
| 필드명 | 타입 | 설명 |
| :--- | :--- | :--- |
| `date` | String | 날짜 (문서 ID와 동일, YYYY-MM-DD) |
| `reference` | String | 성경 구절 정보 (예: "시편 23:1") |
| `scripture` | String | 성경 본문 내용 |
| `pastorNote` | String | 목사님 묵상 포인트/가이드 |

**JSON 예시**:
```json
{
  "date": "2024-12-09",
  "reference": "시편 23:1",
  "scripture": "여호와는 나의 목자시니...",
  "pastorNote": "선한 목자이신 주님을 신뢰합시다..."
}
```

### C. 묵상 기록 - QT Logs (`qt_logs`)
사용자가 작성한 개별 묵상 내용을 저장합니다.

**문서 경로**: `qt_logs/{qtLogId}`

**필드 (Fields)**:
| 필드명 | 타입 | 설명 |
| :--- | :--- | :--- |
| `userId` | String | 작성자 ID (`users` 컬렉션 참조) |
| `date` | String | 묵상 날짜 (YYYY-MM-DD) |
| `title` | String | 묵상 제목 |
| `content` | String | 묵상 본문 (깨달은 점) |
| `application` | String | 적용할 점 |
| `prayer` | String | 개인 기도 내용 |
| `isPublic` | Boolean | 공개 여부 (나눔) |
| `createdAt` | Timestamp | 작성 시간 |

*인덱싱 팁*: "특정 날짜의 다른 사람들 묵상"을 조회하기 위해 `date` + `userId` (또는 `isPublic`) 복합 인덱스가 필요할 수 있습니다.

**JSON 예시**:
```json
{
  "userId": "u1",
  "date": "2024-12-09",
  "title": "주님은 나의 목자",
  "content": "오늘 말씀을 통해 깨달은 것은...",
  "application": "잠들기 전 기도하기",
  "prayer": "주님 도와주세요...",
  "isPublic": true,
  "createdAt": 1702166400000
}
```

### D. 기도 요청 - Prayer Requests (`prayer_requests`)
사용자들이 공유한 기도 제목을 저장합니다.

**문서 경로**: `prayer_requests/{requestId}`

**필드 (Fields)**:
| 필드명 | 타입 | 설명 |
| :--- | :--- | :--- |
| `userId` | String | 작성자 ID |
| `userName` | String | 작성자 이름 (표시용 캐싱) |
| `userAvatar` | String | 작성자 프로필 URL (표시용 캐싱) |
| `content` | String | 기도 요청 내용 |
| `type` | String | 요청 유형 ('INTERCESSORY': 중보기도, 'ONE_ON_ONE': 1:1요청) |
| `createdAt` | Timestamp | 작성 시간 |
| `amenCount` | Number | '아멘' 클릭 수 |
| `amens` | Array<String> | 아멘을 누른 사용자 ID 목록 (선택 사항, `isAmenedByMe` 확인용) |

*참고 (`isAmenedByMe`)*: 클라이언트 앱에서는 `amens` 배열에 `currentUser.id`가 포함되어 있는지 확인하여 '내가 아멘을 눌렀는지' 판단하거나, 별도의 하위 컬렉션을 사용할 수 있습니다. 현재 구조에서는 편의상 로컬 상태로 처리 중이나, 실제로는 배열이나 서브 컬렉션이 필요합니다.

**JSON 예시**:
```json
{
  "userId": "u2",
  "userName": "김철수",
  "userAvatar": "https://...",
  "content": "이번 중요 면접을 위해 기도해주세요...",
  "type": "INTERCESSORY",
  "createdAt": 1702166400000,
  "amenCount": 12,
  "amens": ["u1", "u5", "u9"]
}
```

## 3. 연동 계획 (Integration Plan)

1.  **Firebase 초기화**: `pubspec.yaml`에 `firebase_core`와 `cloud_firestore` 패키지를 추가합니다.
2.  **AppProvider 업데이트**: 
    -   로컬 리스트(`_qtLogs` 등)를 Firestore의 `Stream`이나 `Future`로 대체합니다.
    -   예: `FirebaseFirestore.instance.collection('qt_logs').snapshots()`
3.  **데이터 변환**: 모델 클래스에 추가된 `.fromMap()` 및 `.toMap()` 메서드를 사용하여 Firestore 데이터와 앱의 객체를 변환합니다.

## 4. 쿼리 예시 (Query Examples)

-   **내 묵상 가져오기**: 
    `collection('qt_logs').where('userId', isEqualTo: currentUserId)`
-   **특정 날짜의 다른 사람 묵상 가져오기 (공개된 것만)**: 
    `collection('qt_logs').where('date', isEqualTo: selectedDate).where('isPublic', isEqualTo: true)`
-   **기도 요청 목록 가져오기 (최신순)**:
    `collection('prayer_requests').orderBy('createdAt', descending: true)`
