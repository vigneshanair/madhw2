import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _roleController = TextEditingController();

  bool _loading = true;

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirestoreService.instance.getUserProfile(user.uid);
    final data = doc.data() ?? {};

    _firstNameController.text = (data['firstName'] ?? '') as String;
    _lastNameController.text = (data['lastName'] ?? '') as String;
    _roleController.text = (data['role'] ?? '') as String;

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService.instance.updateUserProfile(
      uid: user.uid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      role: _roleController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'First name',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Last name',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _roleController,
                      label: 'Role',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
