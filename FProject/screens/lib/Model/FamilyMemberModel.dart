class FamilyMemberModel {
  final int familyId;
  final String uid;
  final String guardianId;
  final String relationship;
  final String guardianName;
  final String guardianContact;

  FamilyMemberModel({
    required this.familyId,
    required this.uid,
    required this.guardianId,
    required this.relationship,
    required this.guardianName,
    required this.guardianContact,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      familyId: json['Family_Id'] ?? json['family_Id'] ?? 0,
      uid: json['Uid'] ?? json['uid'] ?? "",
      guardianId: json['Guardian_Id'] ?? json['guardian_Id'] ?? "",
      relationship: json['Relationship'] ?? json['relationship'] ?? "Guardian",
      guardianName: json['GuardianName'] ?? json['guardianName'] ?? (json['Guardian_Id'] ?? ""),
      guardianContact: json['GuardianContact'] ?? json['guardianContact'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Family_Id': familyId,
      'Uid': uid,
      'Guardian_Id': guardianId,
      'Relationship': relationship,
      'GuardianName': guardianName,
      'GuardianContact': guardianContact,
    };
  }
}
