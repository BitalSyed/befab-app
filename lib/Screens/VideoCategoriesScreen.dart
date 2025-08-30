// video_categories_screen.dart
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:video_player/video_player.dart';

class VideoCategoriesScreen extends StatefulWidget {
  const VideoCategoriesScreen({super.key});

  @override
  State<VideoCategoriesScreen> createState() => _VideoCategoriesScreenState();
}

class _VideoCategoriesScreenState extends State<VideoCategoriesScreen> {
  String selectedCategory = "BeFAB NCCU";
  List<dynamic> videos = [];
  bool loading = true;
  Set<String> likedVideos = {}; // Track which videos the user has liked

  final storage = const FlutterSecureStorage();
  Map<String, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() => loading = true);

    try {
      final token = await storage.read(key: "token");
      final url =
          "${dotenv.env['BACKEND_URL']}/app/videos?category=${Uri.encodeComponent(selectedCategory)}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final videosData = json.decode(response.body) as List<dynamic>;
        
        // Check if user has liked each video
        await _checkLikedVideos(videosData, token!);
        
        setState(() {
          videos = videosData;
        });
      } else {
        print("Failed: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  // Check if user has liked each video
  Future<void> _checkLikedVideos(List<dynamic> videos, String token) async {
    try {
      // Fetch all liked videos at once
      final likedResponse = await http.get(
        Uri.parse("${dotenv.env['BACKEND_URL']}/app/videos/liked/get"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (likedResponse.statusCode == 200) {
        final likedVideosList = json.decode(likedResponse.body) as List<dynamic>;
        debugPrint("Liked videos: $likedVideosList");
        final likedVideoIds = likedVideosList.map((id) => id.toString()).toSet();
        
        setState(() {
          likedVideos = likedVideoIds;
        });
        
        // Update each video with like status
        for (var video in videos) {
          final videoId = video["_id"].toString();
          video["isLikedByUser"] = likedVideoIds.contains(videoId);
        }
      } else {
        print("Failed to fetch liked videos: ${likedResponse.body}");
        // If we can't fetch liked videos, assume none are liked
        for (var video in videos) {
          video["isLikedByUser"] = false;
        }
      }
    } catch (e) {
      print("Error checking liked videos: $e");
      // If there's an error, assume none are liked
      for (var video in videos) {
        video["isLikedByUser"] = false;
      }
    }
  }

  void onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
    });
    fetchVideos();
  }

  Future<VideoPlayerController> _initializeVideo(String url) async {
    if (_controllers.containsKey(url)) return _controllers[url]!;

    final controller = VideoPlayerController.network(
      "${dotenv.env['BACKEND_URL']}/$url",
    );
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(0);
    controller.play();

    _controllers[url] = controller;
    return controller;
  }

  Future<void> toggleLike(String videoId, int index) async {
    try {
      final token = await storage.read(key: "token");
      final url = "${dotenv.env['BACKEND_URL']}/app/videos/$videoId/like";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        setState(() {
          // Update likes count
          videos[index]["likes"] = List.filled(body["likes"], "x");
          
          // Update liked status
          if (likedVideos.contains(videoId)) {
            likedVideos.remove(videoId);
            videos[index]["isLikedByUser"] = false;
          } else {
            likedVideos.add(videoId);
            videos[index]["isLikedByUser"] = true;
          }
        });
      } else {
        print("Failed to like: ${response.body}");
      }
    } catch (e) {
      print("Error liking: $e");
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToggleButtonsRow(
            selected: selectedCategory,
            onChanged: onCategoryChanged,
          ),
          Expanded(
            child:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : videos.isEmpty
                    ? const Center(child: Text("No videos found"))
                    : GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      padding: const EdgeInsets.all(16),
                      children:
                          videos.asMap().entries.map((entry) {
                            final index = entry.key;
                            final video = entry.value;
                            final videoId = video["_id"];
                            final isLiked = video["isLikedByUser"] == true;
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/single-video',
                                  arguments: video,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: SizedBox(
                                        height: 220,
                                        width: double.infinity,
                                        child:
                                            video["thumbnailUrl"] != null
                                                ? Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.network(
                                                      "${dotenv.env['BACKEND_URL']}${video["thumbnailUrl"]}",
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      color:
                                                          Colors
                                                              .black26, // slight overlay for better contrast
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .play_circle_fill,
                                                          size: 50,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : Container(
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.videocam,
                                                      size: 50,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      video["title"] ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // CircleAvatar(
                                        //   radius: 14,
                                        //   backgroundImage: NetworkImage(
                                        //     "${dotenv.env['BACKEND_URL']}${video['uploader']['avatarUrl'] ?? '/BeFab.png'}",
                                        //   ),
                                        // ),
                                        const SizedBox(width: 3),
                                        Text(
                                          video["uploader"]['username'] ??
                                              "Unknown",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap:
                                              () => toggleLike(
                                                videoId,
                                                index,
                                              ),
                                          child: Row(
                                            children: [
                                              // Use different icon based on like status
                                              isLiked
                                                ? Image.asset(
                                                    'assets/images/redheart.png',
                                                    width: 16,
                                                    height: 16,
                                                  )
                                                : SvgPicture.asset(
                                                    'assets/images/like.svg',
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                              const SizedBox(width: 3),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 4.0,
                                                ),
                                                child: Text(
                                                  "${(video["likes"] as List).length}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: isLiked 
                                                      ? const Color(0xFF862633) // Red color for liked count
                                                      : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
          ),
        ],
      ),
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
            Navigator.pushNamed(context, "/all-reels");
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }
}

class ToggleButtonsRow extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const ToggleButtonsRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels = const ['BeFAB NCCU', 'Mentor Meetup', 'Students'];

  @override
  Widget build(BuildContext context) {
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
            children:
                labels.map((label) {
                  final isSelected = selected == label;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF862633)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF862633)
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: isSelected ? 15 : 14,
                            color:
                                isSelected
                                    ? Colors.white
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