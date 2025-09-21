class Account {
  final String id;
  final String? username;
  final String accountType;
  final String? phoneNumber;
  final String? profilePictureUrl;

  Account({
    required this.id,
    this.username,
    this.accountType = 'CUSTOMER',
    this.phoneNumber,
    this.profilePictureUrl,
  });

  factory Account.fromJson(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      username: map['username'],
      accountType: map['account_type'] ?? 'CUSTOMER',
      phoneNumber: map['phone_number'],
      profilePictureUrl: map['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'account_type': accountType,
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
    };
  }
}
