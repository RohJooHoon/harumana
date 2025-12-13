#!/bin/bash

# Flutter Android 빌드 및 실행 스크립트

echo "🔍 연결된 디바이스 검색 중..."
devices=$(flutter devices --machine)

# 디바이스 목록 파싱 및 표시
echo ""
echo "📱 사용 가능한 디바이스:"
echo "$devices" | jq -r '.[] | "\(.id) - \(.name) (\(.platform))"' | cat -n

echo ""
read -p "디바이스 번호를 선택하세요: " device_num

# 선택한 디바이스 ID 가져오기
device_id=$(echo "$devices" | jq -r ".[$((device_num-1))].id")

if [ -z "$device_id" ] || [ "$device_id" = "null" ]; then
    echo "❌ 잘못된 선택입니다."
    exit 1
fi

echo ""
echo "✅ 선택된 디바이스: $device_id"
echo ""
echo "🔨 릴리즈 모드로 빌드 및 실행합니다..."
flutter run --release -d "$device_id"

# 결과 출력
echo ""
echo "✅ 설치 및 실행 명령이 전송되었습니다."
echo "   (로그 연결이 끊겨도 앱은 정상적으로 설치되었을 수 있습니다.)"
echo "   안드로이드 디바이스를 확인해주세요."
exit 0
