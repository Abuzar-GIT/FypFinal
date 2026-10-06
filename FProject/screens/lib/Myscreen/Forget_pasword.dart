import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:screens/Api/Api.dart';

class ForgetPasword extends StatefulWidget {
  const ForgetPasword({super.key});

  @override
  State<ForgetPasword> createState() => _ForgetPaswordState();
}

class _ForgetPaswordState extends State<ForgetPasword> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureText1 = true;
  @override
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(231, 216, 217, 216),

      body: GestureDetector(
        //onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                color: Color.fromARGB(0, 248, 122, 4),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        //color: Colors.blueAccent,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,

                          border: Border.all(color: Colors.black, width: 4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.key,
                          color: Color.fromARGB(255, 217, 97, 30),
                          size: 50,
                        ),
                      ),
                    ),
                    //text
                    const SizedBox(height: 15),
                    const Text(
                      "Reset Your Password",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      // textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Enter your details To set a new password ",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    //
                    Container(
                      padding: EdgeInsets.only(top: 6),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                decorationColor: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: email,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter your email",
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter Your Registered Email";
                                }
                                if (!value.contains('@')) {
                                  return "Email must contain '@'";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            //New Password
                            Text(
                              'New Password',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                decorationColor: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              controller: password,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () => {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    }),
                                  },
                                ),
                                // suffixIcon: Icon(Onp Icons.remove_red_eye,),
                                border: OutlineInputBorder(),
                                hintText: "Enter your Password",
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password required";
                                }
                                if (value.length <= 8) {
                                  return "Must be greater than 8 characters long";
                                }
                                if (!RegExp(r'^[A-Z]').hasMatch(value)) {
                                  return "Must start with a capital letter";
                                }
                                if (!RegExp(r'\d').hasMatch(value)) {
                                  return "Must contain at least one number";
                                }
                                if (!RegExp(r'[@$!%*?&#]').hasMatch(value)) {
                                  return "Must contain at least one special character";
                                }
                                return null;
                              },
                            ),
                            const Text(
                              "Must be Atleast 8 Character long ",
                              style: TextStyle(fontSize: 13),
                            ),
                            SizedBox(height: 8),

                            //confirm password
                            Text(
                              'Confirm Password',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                decorationColor: Colors.deepOrange,
                              ),
                            ),
                            SizedBox(height: 5),
                            TextFormField(
                              obscureText: _obscureText1,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () => {
                                    setState(() {
                                      _obscureText1 = !_obscureText1;
                                    }),
                                  },
                                  icon: Icon(Icons.remove_red_eye),
                                ),
                                border: OutlineInputBorder(),
                                hintText: "Renter password",
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Confirm Password required";
                                }
                                if (value != password.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),

                            /// LOGIN BUTTON
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  print("Email: ${email.text}");
                                  print("Password: ${password.text}");

                                  //   // Navigator.push(
                                  //   //   context,
                                  //   //   // MaterialPageRoute(
                                  //   //   //   builder: (context) =>
                                  //   //   //     //  Regestration(
                                  //   //   //      //   name:username.text,
                                  //   //   //      // ),
                                  //   //   // ),
                                  //   // );
                                }
                              },

                              child: Container(
                                height: 45,
                                width: double.infinity,

                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,

                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    http.Response response =
                                        await ApiInterface.ForgetPassword(
                                          email: email.text,
                                          newPassword: password.text,
                                          confirmPassword: password.text,
                                        );

                                    if (response.statusCode == 200) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password reset successful',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      email.clear();
                                      password.clear();

                                      // OPTIONAL: also reset form validation state
                                      _formKey.currentState!.reset();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to reset password',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },

                                  icon: const Icon(
                                    Icons.key,
                                    color: Colors.white,
                                  ),

                                  label: const Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.blue, // change as needed
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            ///text button
                            SizedBox(height: 7),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                // border: Border.all(color: Colors.red, width: 5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    //MaterialPageRoute(builder: (context)=>LogIn())
                                  );
                                  setState(() {
                                    email.clear();
                                    password.clear();
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back),
                                    SizedBox(width: 5),
                                    Text('Back to Login'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
