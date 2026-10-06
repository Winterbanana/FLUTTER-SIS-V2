import 'package:flutter/material.dart';

import '../models/app_user.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 80,
                ),

                const SizedBox(height: 20),

                Text(
                  'Username: ${user.username}',
                  style:
                      const TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Role: ${user.role}',
                  style:
                      const TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'User ID: ${user.id}',
                  style:
                      const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}