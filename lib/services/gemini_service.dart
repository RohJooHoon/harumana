import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/qt_guide_response.dart';

// WARNING: Hardcoding API keys is not recommended. 
// In a real app, use --dart-define or .env
const String apiKey = String.fromEnvironment('API_KEY'); 

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey.isNotEmpty ? apiKey : 'PLACEHOLDER_KEY', 
    );
  }

  Future<QTGuideResponse> generateQTGuide(String scripture) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key not found. Please run with --dart-define=API_KEY=...');
    }

    final prompt = '''
    오늘의 말씀 본문: "$scripture". 
    이 말씀을 바탕으로 묵상을 돕기 위한 가이드를 작성해줘.
    다음 세 가지 요소를 포함해야 해:
    1. 말씀의 배경 (1줄 요약)
    2. 묵상을 위한 질문 (2가지)
    3. 삶의 적용점 (1가지)

    Output JSON format:
    {
      "background": "String",
      "questions": ["String", "String"],
      "action": "String"
    }
    ''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    final text = response.text;

    if (text == null) throw Exception('Failed to generate content');

    // Clean up potential markdown code blocks
    final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
    
    try {
      final json = jsonDecode(cleanText);
      return QTGuideResponse.fromJson(json);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  Future<String> refinePrayer(String rawText) async {
    if (apiKey.isEmpty) {
       // Mock behavior if no key
       await Future.delayed(const Duration(seconds: 1));
       return "[AI 다듬음 (Key Missing)] $rawText";
    }

    final prompt = '''
    다음은 사용자가 작성한 기도 제목의 초안이야: "$rawText".
    이 내용을 공동체에 나누기 적합하도록 정중하고 은혜로운 기독교적 문체('~해요', '~습니다' 체)로 다듬어줘.
    원래의 의도는 유지하되, 더 간절하고 따뜻한 표현을 사용해줘.
    결과물은 다듬어진 텍스트만 출력해.
    ''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? rawText;
  }
}
