

class Usermodel {
  String uid;
  String name;
  String password;
  String role;
  String contactNo;

  Usermodel({
    required this.uid,
    required this.name,
    required this.password,
    required this.role,
    required this.contactNo,
  });
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'password': password,
      'role': role,
      'contact_no': contactNo,
    };
  }

  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(
      uid: json["Uid"] ?? "",
      name: json["Name"] ?? "",
      password: json["Password"] ?? "",
      role: json["Role"] ?? "",
      contactNo: json["Contact_No"] ?? "",
    );
  }
}
