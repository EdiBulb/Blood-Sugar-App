import 'dart:math';

class BloodSugarTips {
  static final List<String> _tips = [
    "정제된 탄수화물 섭취를 줄이세요.",
    "식사 후 30분 동안 가벼운 산책을 해보세요.",
    "물을 충분히 마시면 혈당 조절에 도움이 됩니다.",
    "야채와 단백질을 먼저 먹고 탄수화물을 나중에 섭취하세요.",
    "가공식품 대신 자연식품을 섭취하세요.",
    "하루 7시간 이상의 충분한 수면을 취하세요.",
    "스트레스를 줄이면 혈당 관리에 좋습니다.",
    "정기적으로 혈당을 측정하고 기록하세요.",
    "설탕이 많이 들어간 음료를 피하세요.",
    "견과류를 간식으로 먹으면 혈당 조절에 도움이 됩니다."
  ];

  static String getRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }
}
