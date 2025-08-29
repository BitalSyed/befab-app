import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String groupImage;
  final String groupName;
  final String groupType;
  final String postedTime;
  final String membersCount;
  final String description;
  final String imageUrls;
  final String state;
  final String groupId;
  final VoidCallback onJoinPressed;
  final VoidCallback? onGroupTap; // 👈 one callback for all taps

  const GroupCard({
    super.key,
    required this.groupImage,
    required this.groupName,
    required this.groupType,
    required this.postedTime,
    required this.membersCount,
    required this.description,
    required this.imageUrls,
    required this.state,
    required this.groupId,
    required this.onJoinPressed,
    this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top Info Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /// 👇 Group Image clickable
              GestureDetector(
                onTap:
                    onGroupTap ??
                    () {
                      Navigator.pushNamed(
          context,
          '/fitness-group',
          arguments: {"id": groupId}, // 👈 send _id
        );
                    },
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(groupImage),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 👇 Group Name clickable
                    GestureDetector(
                      onTap:
                          onGroupTap ??
                          () {
                            Navigator.pushNamed(
          context,
          '/fitness-group',
          arguments: {"id": groupId}, // 👈 send _id
        );
                          },
                      child: Text(
                        groupName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue, // to hint it's clickable
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    /// 👇 Group Type clickable (postedTime is not clickable)
                    GestureDetector(
                      onTap:
                          onGroupTap ??
                          () {
                            Navigator.pushNamed(
          context,
          '/fitness-group',
          arguments: {"id": groupId}, // 👈 send _id
        );
                          },
                      child: Text(
                        '$groupType · $postedTime\n$membersCount Members',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// JOIN button
              TextButton(
                onPressed: onJoinPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  state,
                  style: TextStyle(color: Color(0xFF121217), fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        /// Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(description, style: const TextStyle(fontSize: 14)),
        ),

        const SizedBox(height: 12),

        /// Images Layout
        Image.network(
          imageUrls, // 👈 it's already a single string
          width: screenWidth,
          height: 240,
          fit: BoxFit.cover,
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
