class UserProfile {
  final String? name;
  final String? businessDetails;
  final String? phoneNumber;
  final String? profilePhotoPath;

  UserProfile({this.name, this.businessDetails, this.phoneNumber, this.profilePhotoPath});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'businessDetails': businessDetails,
      'phoneNumber': phoneNumber,
      'profilePhotoPath': profilePhotoPath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      businessDetails: json['businessDetails'],
      phoneNumber: json['phoneNumber'],
      profilePhotoPath: json['profilePhotoPath'],
    );
  }

  UserProfile copyWith({String? name, String? businessDetails, String? phoneNumber, String? profilePhotoPath}) {
    return UserProfile(
      name: name ?? this.name,
      businessDetails: businessDetails ?? this.businessDetails,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
    );
  }

  bool get isComplete {
    return name != null &&
        name!.isNotEmpty &&
        businessDetails != null &&
        businessDetails!.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty &&
        profilePhotoPath != null &&
        profilePhotoPath!.isNotEmpty;
  }
}
