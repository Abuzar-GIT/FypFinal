import 'package:flutter/material.dart';
import 'package:screens/Api/Api.dart';
import 'package:screens/Model/FamilyMemberModel.dart';
import 'package:screens/Myscreen/alert_screen.dart';

class FamilyMembersScreen extends StatefulWidget {
  final String email;

  const FamilyMembersScreen({super.key, required this.email});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final TextEditingController _guardianIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _relationships = [
    "Parent",
    "Father",
    "Mother",
    "Spouse",
    "Sibling",
    "Child",
    "Guardian",
    "Friend",
  ];

  String _selectedRelationship = "Guardian";
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<FamilyMemberModel> _guardians = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGuardians();
  }

  @override
  void dispose() {
    _guardianIdController.dispose();
    super.dispose();
  }

  Future<void> _loadGuardians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiInterface.getGuardians(widget.email);
      if (mounted) {
        setState(() {
          _guardians = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load guardians: $e";
        });
      }
    }
  }

  Future<void> _handleAddFamilyMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final res = await ApiInterface.addFamilyMember(
        uid: widget.email,
        guardianId: _guardianIdController.text.trim(),
        relationship: _selectedRelationship,
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        _guardianIdController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Family member / Guardian added successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _loadGuardians();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add: ${res.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text("Family & Guardians"),
        backgroundColor: const Color(0xFFFC840D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: "View Emergency Alerts",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertScreen(
                    isRescue: false,
                    uid: widget.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: Color(0xFFFC840D), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Emergency Contact Network",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Guardians added here receive instant emergency alerts with real-time location tracking whenever an accident is detected.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Add form card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_add_alt_1_rounded, color: Color(0xFFFC840D)),
                          SizedBox(width: 8),
                          Text(
                            "Add Guardian / Family Member",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text("Guardian User ID (Email)", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _guardianIdController,
                        decoration: InputDecoration(
                          hintText: "Enter guardian's registered user ID / email",
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Guardian User ID is required";
                          if (v.trim().toLowerCase() == widget.email.trim().toLowerCase()) {
                            return "You cannot add yourself as your own guardian";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      const Text("Relationship", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRelationship,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.family_restroom_rounded),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: _relationships.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRelationship = val;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.add_circle_outline),
                          label: Text(_isSubmitting ? "Adding..." : "Add Guardian"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFC840D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isSubmitting ? null : _handleAddFamilyMember,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Guardians List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Added Guardians",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Refresh"),
                    onPressed: _loadGuardians,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                )
              else if (_guardians.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 45, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        "No guardians added yet",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Add a family member above so they receive alert notifications with your location if an accident occurs.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _guardians.length,
                  itemBuilder: (ctx, i) {
                    final g = _guardians[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFC840D).withOpacity(0.15),
                            child: Text(
                              g.guardianId.isNotEmpty ? g.guardianId[0].toUpperCase() : "G",
                              style: const TextStyle(color: Color(0xFFFC840D), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.guardianId,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                if (g.guardianContact.isNotEmpty)
                                  Text(
                                    "Contact: ${g.guardianContact}",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Text(
                              g.relationship,
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
