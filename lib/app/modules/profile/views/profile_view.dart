import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../components/custom_form_field.dart';
import '../controllers/profile_controller.dart';
import '../../home/controllers/home_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String removeCountryCode(String phoneNumber) {
      if (phoneNumber.startsWith('+91')) {
        return phoneNumber.substring(3).trim();
      }
      return phoneNumber.trim();
    }

    String localUsername = '';
    String localEmail = '';
    String localPhoneNumber = '';
    String localPanNumber = '';
    String localLegalEntityName = '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          return ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: ClipOval(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : Image.network(
                              (controller.userAvatar.value == null ||
                                      controller.userAvatar.value!.isEmpty)
                                  ? ''
                                  : controller.userAvatar.value!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 50),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(homeController.currentUser)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data?.data() == null) {
                    return const Center(
                        child: Text('Failed to load user data'));
                  }

                  final data = snapshot.data?.data();
                  localUsername = data?['username'] ?? 'Guest';
                  localEmail = data?['email'] ?? 'guest@example.com';
                  localPhoneNumber = removeCountryCode(
                      data?['phoneNumber'] ?? homeController.currentUser);
                  localPanNumber = data?['panNumber'] ?? '';
                  localLegalEntityName = data?['legalEntityName'] ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        title: 'Full Name',
                        value: localUsername,
                        controller: controller,
                        theme: theme,
                        onSave: (value) {
                          localUsername = value ?? localUsername;
                        },
                      ),
                      _buildInfoCard(
                        title: 'Email Address',
                        value: localEmail,
                        controller: controller,
                        theme: theme,
                        onSave: (value) {
                          localEmail = value ?? localEmail;
                        },
                      ),
                      _buildInfoCard(
                        title: 'Phone Number',
                        value: localPhoneNumber,
                        controller: controller,
                        theme: theme,
                        onSave: (value) {
                          localPhoneNumber = value ?? localPhoneNumber;
                        },
                      ),
                      _buildInfoCard(
                        title: 'PAN Number',
                        value: localPanNumber,
                        controller: controller,
                        theme: theme,
                        onSave: (value) {
                          localPanNumber = value ?? localPanNumber;
                        },
                      ),
                      _buildInfoCard(
                        title: 'Legal Entity Name',
                        value: localLegalEntityName,
                        controller: controller,
                        theme: theme,
                        onSave: (value) {
                          localLegalEntityName = value ?? localLegalEntityName;
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (controller.isEditing.value) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(homeController.currentUser)
                                  .update({
                                'username': localUsername,
                                'email': localEmail,
                                'phoneNumber': '+91$localPhoneNumber',
                                'panNumber': localPanNumber,
                                'legalEntityName': localLegalEntityName,
                              });

                              await controller.fetchUserDetails();
                              controller.toggleEditing();
                            } else {
                              controller.toggleEditing();
                            }
                          },
                          child: Text(controller.isEditing.value
                              ? 'Save Changes'
                              : 'Edit Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required ProfileController controller,
    required ThemeData theme,
    required Function(String?) onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: controller.isEditing.value
                ? CustomFormField(
                    hint: 'Update $title',
                    initialValue: value,
                    onChanged: onSave,
                    label: title,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(value, style: theme.textTheme.bodyLarge),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
