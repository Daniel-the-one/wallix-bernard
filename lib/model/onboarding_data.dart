

class OnboardingPageData {
  final String titleKey;
  final String descriptionKey;
  final String imagePlaceholder;

  const OnboardingPageData({
    required this.titleKey,
    required this.descriptionKey,
    required this.imagePlaceholder,
  });
}

class OnboardingData {
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      titleKey: 'onboarding_1_title',
      descriptionKey: 'onboarding_1_desc',
      imagePlaceholder: 'assets/images/onboarding_1.png',
    ),
    OnboardingPageData(
      titleKey: 'onboarding_2_title',
      descriptionKey: 'onboarding_2_desc',
      imagePlaceholder: 'assets/images/onboarding_2.png',
    ),
  ];
}
