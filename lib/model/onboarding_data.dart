class OnboardingPageData {
  final String title;
  final String description;
  final String imagePlaceholder;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePlaceholder,
  });
}

class OnboardingData {
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'Gestion instantanée\ndes transferts',
      description:
          'Enregistrez, validez et suivez chaque\ntransaction de vos clients en temps réel.',
      imagePlaceholder: 'assets/images/onboarding_1.png', // <- METS TON IMAGE ICI
    ),
    OnboardingPageData(
      title: 'Sécurisé et\nde confiance',
      description:
          'Chaque opération est protégée pour\ngarantir la confiance de vos clients.',
      imagePlaceholder: 'assets/images/onboarding_2.png', // <- METS TON IMAGE ICI
    ),
  ];
}