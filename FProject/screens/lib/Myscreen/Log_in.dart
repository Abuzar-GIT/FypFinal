import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:screens/Admin/AdminDashboard.dart';
import 'package:screens/Api/Api.dart';
import 'package:screens/Model/UserModel.dart';
import 'package:screens/Myscreen/Forget_pasword.dart';
import 'package:screens/Myscreen/Regester.dart';
import 'package:screens/Myscreen/Select_vechile.dart';
import 'package:screens/Myscreen/alert_screen.dart';
import 'package:screens/Services/location_service.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController email = TextEditingController();
  final TextEditingController ip = TextEditingController(
    text: "192.168.31.189",
  );
  final TextEditingController password = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  // Rescue login state
  bool isRescueMode = false;
  final TextEditingController rescueRid = TextEditingController();
  final TextEditingController rescuePassword = TextEditingController();
  final FocusNode rescueRidFocus = FocusNode();
  final FocusNode rescuePasswordFocus = FocusNode();
  bool _rescueObscureText = true;
  bool _isRescueLoading = false;
  final _rescueFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();

    ApiInterface.ip = ip.text.trim();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    rescueRid.dispose();
    rescuePassword.dispose();
    rescueRidFocus.dispose();
    rescuePasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRescueLogin() async {
    if (ApiInterface.ip.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set server IP first")),
      );
      return;
    }

    if (!_rescueFormKey.currentState!.validate()) return;

    setState(() {
      _isRescueLoading = true;
    });

    try {
      final pos = await LocationService.getCurrentPosition();
      final locStr = LocationService.formatPosition(pos);

      final rid = int.parse(rescueRid.text.trim());
      final res = await ApiInterface.rescueLogin(
        rid: rid,
        password: rescuePassword.text.trim(),
        location: locStr,
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final loggedInRid = data["Rid"] ?? rid;

        // Redirect directly to Alerts page - strictly no other page accessible to Rescue
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlertScreen(isRescue: true, rid: loggedInRid),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rescue login failed: ${res.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error logging in as Rescue: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRescueLoading = false;
        });
      }
    }
  }

  void _showRescueRegisterDialog() {
    if (ApiInterface.ip.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set server IP first")),
      );
      return;
    }

    final regLocationController = TextEditingController();
    final regPwdController = TextEditingController();
    bool isFetchingGps = false;
    bool isRegSubmitting = false;
    bool regPwdObscure = true;

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.local_hospital_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Register Rescue Unit"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Register a new rescue team unit. Click the GPS link button to automatically fill your current coordinates.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // First Textbox with GPS link button in front/beside it
                    const Text(
                      "GPS Coordinates",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: regLocationController,
                            decoration: const InputDecoration(
                              hintText: "Click GPS or enter Lat, Lng",
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                size: 20,
                              ),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isFetchingGps
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isFetchingGps = true;
                                  });
                                  try {
                                    final pos =
                                        await LocationService.getCurrentPosition();
                                    if (pos != null) {
                                      final locStr =
                                          LocationService.formatPosition(pos);
                                      regLocationController.text = locStr;
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "GPS coordinates acquired: $locStr",
                                            ),
                                            backgroundColor:
                                                Colors.green.shade700,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Could not acquire GPS position. Ensure location is enabled.",
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("GPS Error: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    setDialogState(() {
                                      isFetchingGps = false;
                                    });
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isFetchingGps)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blue,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.my_location_rounded,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                const SizedBox(width: 4),
                                const Text(
                                  "GPS",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Second Textbox: Password
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: regPwdController,
                      obscureText: regPwdObscure,
                      decoration: InputDecoration(
                        hintText: "Enter rescue unit password",
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            regPwdObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              regPwdObscure = !regPwdObscure;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isRegSubmitting ? null : () => Navigator.pop(dCtx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isRegSubmitting
                      ? null
                      : () async {
                          if (regLocationController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please click 'GPS' or enter coordinates",
                                ),
                              ),
                            );
                            return;
                          }

                          if (regPwdController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password is required"),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isRegSubmitting = true;
                          });

                          try {
                            final res = await ApiInterface.rescueRegister(
                              password: regPwdController.text.trim(),
                              location: regLocationController.text.trim(),
                            );

                            if (!dCtx.mounted) return;

                            if (res.statusCode == 200) {
                              final data = jsonDecode(res.body);
                              final newRid = data["Rid"];
                              Navigator.pop(dCtx);

                              rescueRid.text = "$newRid";
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Rescue Unit registered! Your RID is #$newRid. You can now login.",
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 6),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Registration failed: ${res.body}",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error registering rescue unit: $e",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (dCtx.mounted) {
                              setDialogState(() {
                                isRegSubmitting = false;
                              });
                            }
                          }
                        },
                  child: isRegSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Register"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // keyboardDismissBehavior:
          //     ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  /// LOGO
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(50),
                      color: const Color(0xFFFC840D).withOpacity(0.9),
                    ),
                    child: const Icon(
                      Icons.safety_check_rounded,
                      color: Color.fromARGB(255, 217, 97, 30),
                      size: 70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Accident Detection System",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Login to Your Account",
                    style: TextStyle(fontSize: 18),
                  ),

                  //ip
                  // TextFormField(
                  //   controller: ip,
                  //   decoration: const InputDecoration(
                  //     hintText: "Enter your IP",
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  const SizedBox(height: 10),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (ip.text.trim().isEmpty) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //           content: Text("Please enter IP address"),
                  //         ),
                  //       );
                  //       return;
                  //     }

                  //     // Send IP to ApiInterface
                  //     ApiInterface.ip = ip.text.trim();

                  //     print("IP: ${ApiInterface.ip}");
                  //     print("Base URL: ${ApiInterface.baseUrl}");

                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text("IP assigned successfully"),
                  //       ),
                  //     );
                  //   },
                  //   child: const Text("Set IP"),
                  // ),
                  const SizedBox(height: 20),

                  /// ROLE TOGGLE: User vs Rescue
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                isRescueMode = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: !isRescueMode
                                    ? const Color(0xFFFC840D)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 18,
                                    color: !isRescueMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "User / Driver",
                                    style: TextStyle(
                                      color: !isRescueMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                isRescueMode = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: isRescueMode
                                    ? Colors.red.shade700
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_hospital_rounded,
                                    size: 18,
                                    color: isRescueMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Rescue Unit",
                                    style: TextStyle(
                                      color: isRescueMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isRescueMode) ...[
                    /// RESCUE LOGIN FORM
                    Form(
                      key: _rescueFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rescue Unit ID (RID)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: rescueRid,
                            focusNode: rescueRidFocus,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Enter Rescue ID (e.g. 1)",
                              prefixIcon: Icon(Icons.tag_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Rescue ID is required";
                              }
                              if (int.tryParse(val.trim()) == null) {
                                return "Enter valid numeric RID";
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(rescuePasswordFocus),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: rescuePassword,
                            focusNode: rescuePasswordFocus,
                            obscureText: _rescueObscureText,
                            decoration: InputDecoration(
                              hintText: "Enter Rescue password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _rescueObscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rescueObscureText = !_rescueObscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              icon: _isRescueLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.local_hospital_rounded),
                              label: Text(
                                _isRescueLoading
                                    ? "Logging in..."
                                    : "Login as Rescue Unit",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isRescueLoading
                                  ? null
                                  : _handleRescueLogin,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: TextButton.icon(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                "Register New Rescue Unit",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _showRescueRegisterDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    /// FORM
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email", style: TextStyle(fontSize: 20)),

                          const SizedBox(height: 5),

                          /// EMAIL FIELD
                          TextFormField(
                            controller: email,
                            focusNode: emailFocus,
                            // obscureText: true,
                            //  keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "Enter your email",
                              border: OutlineInputBorder(),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains('@')) {
                                return "Enter valid email";
                              }
                              return null;
                            },

                            onFieldSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(passwordFocus);
                            },
                          ),

                          const SizedBox(height: 15),

                          /// PASSWORD LABEL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Password",
                                style: TextStyle(fontSize: 20),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgetPasword(),
                                    ),
                                  );
                                  print("Forgot password clicked");
                                },
                                child: const Text(
                                  "Forget Password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          /// PASSWORD FIELD
                          TextFormField(
                            controller: password,
                            focusNode: passwordFocus,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: "Enter password",
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),

                            // VALIDATION
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return "Password required";
                            //   }
                            //   final regex = RegExp//( r'^[A-Za-z\d@$!%*?&]{8,}$' ) ;
                            //   //(r'^[A-Z][a-z]\d[@$!%*?&]{8,}$')
                            //   (r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

                            //     if (!regex.hasMatch(value)) {
                            //        setState(() {
                            //         password.clear();
                            //     });
                            //       return "Password must start with a capital letter followed by exactly 8 digits";

                            // }
                            //   return null;
                            // },
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 25),

                          /// LOGIN BUTTON
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  http.Response response =
                                      await ApiInterface.login(
                                        email.text.trim(),
                                        password.text.trim(),
                                      );

                                  print(
                                    "Response Code: ${response.statusCode}",
                                  );
                                  print("Response Body: ${response.body}");

                                  if (response.statusCode == 200) {
                                    final data = jsonDecode(response.body);

                                    final userinfo = Usermodel.fromJson(
                                      Map<String, dynamic>.from(data),
                                    );

                                    if (userinfo.role.toLowerCase() == "user") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VehicleScreen(
                                            email: userinfo.uid,
                                          ),
                                        ),
                                      );
                                    } else if (userinfo.role.toLowerCase() ==
                                        "admin") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminDashboard(
                                            email: userinfo.uid,
                                          ),
                                          //  AddNewVehicle(UserId: userinfo.uid),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (!mounted) return;

                                    final message =
                                        response.statusCode == 400 ||
                                            response.statusCode == 401 ||
                                            response.statusCode == 403 ||
                                            response.statusCode == 404
                                        ? 'Your password or email is wrong'
                                        : 'Server error. Please try again.';

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print("Error: $e");

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Something went wrong'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              height: 55,
                              width: double.infinity,

                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.red, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, color: Colors.white),

                                  SizedBox(width: 10),

                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// REGISTER
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Don't have an Account?",
                                  style: TextStyle(fontSize: 16),
                                ),

                                const SizedBox(height: 8),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserSignupPage(
                                          // onBackToLogin: () {},
                                          // onSignupSuccess: () {},
                                        ),
                                      ),
                                    );
                                  },

                                  child: const Text(
                                    "Register as User",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
