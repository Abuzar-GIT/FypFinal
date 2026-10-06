import 'package:flutter/material.dart';
import 'package:screens/Api/Api.dart';
import 'package:screens/Model/UserModel.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var user = Usermodel(
        name: nameController.text.trim(),
        uid: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: "User",
        contactNo: contactController.text.trim(),
      );

      var response = await ApiInterface.CreateUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEAEA), Color(0xFFFFF3E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Back"),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Register to get started",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 24),

                      /// FORM CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(blurRadius: 10, color: Colors.black12),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: contactController,
                              decoration: const InputDecoration(
                                labelText: "Contact Number",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : registerUser,
                                icon: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.person_add),
                                label: Text(
                                  isLoading ? "Registering..." : "Register",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextButton.icon(
                        icon: const Icon(Icons.local_hospital_rounded, color: Colors.red, size: 18),
                        label: const Text(
                          "Are you a Rescue Unit? Register / Login here",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
