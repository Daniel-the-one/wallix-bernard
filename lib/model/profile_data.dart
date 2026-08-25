

class ProfileData {
  final String agentCode;
  final String agentName;
  final String phoneNumber;
  final String? avatarUrl;
  final bool isVerified;
  final double solde;

  const ProfileData({
    required this.agentCode,
    this.agentName = 'Agent',
    required this.phoneNumber,
    this.avatarUrl,
    this.isVerified = false,
    this.solde = 0.0,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      agentCode: json['agent_code']?.toString() ?? json['agentName']?.toString() ?? 'Agent',
      agentName: json['agent_name']?.toString() ?? json['agentName']?.toString() ?? 'Agent',
      phoneNumber: json['phone_number']?.toString() ?? json['telephone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? json['agent_photo']?.toString(),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1 || json['verified'] == true,
      solde: (json['solde'] is num) ? (json['solde'] as num).toDouble() : 0.0,
    );
  }
}

typedef ProfileModel = ProfileData;
