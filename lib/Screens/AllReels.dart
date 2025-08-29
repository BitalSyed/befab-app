import 'dart:io';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:befab/components/VideoRow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class AllReels extends StatefulWidget {
  const AllReels({super.key});

  @override
  State<AllReels> createState() => _AllReelsState();
}

class _AllReelsState extends State<AllReels> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo(String category) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // Pass video path + category to /reel for cover editing
      Navigator.pushNamed(
        context,
        '/reel',
        arguments: {
          'videoPath': video.path,
          'category': category,
        },
      );
    }
  }

  Future<void> _recordLive() async {
    // For now just open camera to record
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      Navigator.pushNamed(
        context,
        '/reel',
        arguments: {
          'videoPath': video.path,
          'category': 'Live',
        },
      );
    }
  }

  String selected = 'Reel'; // default selected tab
  final List<String> labels = ['Post', 'Story', 'Reel', 'Live'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  'assets/images/Arrow.svg',
                  width: 14,
                  height: 14,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF862633),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Videos Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/cam.svg',
              width: 18,
              height: 18,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VideoRow(),

              // Instead of demo Grid, show instructions or recent picks
              Expanded(
                child: Center(
                  child: Text(
                    selected == 'Live'
                        ? "Start a live recording"
                        : "Choose a video from gallery for $selected",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),

          // Bottom category tabs
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildCategoryTabs(),
            ),
          ),
        ],
      ),

      // Floating Button triggers action
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: IconButton(
          icon: const Icon(
            Icons.add_circle,
            size: 70,
            color: Color(0xFF862633),
          ),
          onPressed: () {
            if (selected == 'Live') {
              _recordLive();
            } else {
              _pickVideo(selected);
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 48,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFC7C7CC)),
          ),
          child: Row(
            children: labels.map((label) {
              final isSelected = selected == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selected = label;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isSelected ? 15 : 14,
                        color: isSelected
                            ? const Color(0xFF862633)
                            : const Color(0xFF9C9B9D),
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
