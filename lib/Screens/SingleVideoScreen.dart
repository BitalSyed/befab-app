// single_video_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class SingleVideoScreen extends StatefulWidget {
  const SingleVideoScreen({super.key});

  @override
  State<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends State<SingleVideoScreen>
    with WidgetsBindingObserver {
  final storage = const FlutterSecureStorage();

  VideoPlayerController? _controller;

  Map<String, dynamic>? video;
  String? backendUrl;

  bool _initializing = false;
  bool _isReady = false;
  bool _hasError = false;
  String? _errorMsg;

  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupFromArgs());
  }

  Future<void> _setupFromArgs() async {
    if (!mounted) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      setState(() {
        _hasError = true;
        _errorMsg = 'No video provided.';
      });
      return;
    }

    video = args;
    backendUrl = dotenv.env['BACKEND_URL'];

    final likes = (video!['likes'] as List?) ?? const [];
    likeCount = likes.length;

    final url = _buildPlayableUrl('${backendUrl ?? ''}${video!['url'] ?? ''}');
    await _initController(url);
  }

  String _buildPlayableUrl(String raw) {
    if (Platform.isAndroid) {
      if (raw.contains('localhost')) {
        return raw.replaceAll('localhost', '10.0.2.2');
      }
      if (raw.contains('127.0.0.1')) {
        return raw.replaceAll('127.0.0.1', '10.0.2.2');
      }
    }
    return raw;
  }

  Future<void> _initController(String url) async {
    if (_initializing || !mounted) return;
    _initializing = true;
    _hasError = false;
    _errorMsg = null;
    _isReady = false;

    await _disposeController();

    final c = VideoPlayerController.network(
      url,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false, // ✅ fixes background playback
      ),
    );

    c.addListener(() {
      if (c.value.hasError && !_hasError) {
        setState(() {
          _hasError = true;
          _errorMsg = c.value.errorDescription ?? 'Playback error.';
          _isReady = false;
        });
      }
    });

    _controller = c;

    try {
      await Future.any([
        c.initialize(),
        Future.delayed(const Duration(seconds: 12), () {
          throw TimeoutException('Player init timeout');
        })
      ]);

      if (!mounted) return;

      setState(() {
        _isReady = true;
      });

      c.setLooping(true);
      c.play();
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg =
            'Taking too long to load the video. Please check network/URL.';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg =
            'Player error: ${e.message ?? e.code}. Check codec/network.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg = 'Unexpected error: $e';
      });
    } finally {
      _initializing = false;
    }
  }

  Future<void> _disposeController() async {
    try {
      final old = _controller;
      _controller = null;
      if (old != null) {
        await old.pause();
        await old.dispose();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      c.pause();
    } else if (state == AppLifecycleState.resumed && _isReady) {
      c.play();
    }
  }

  Future<void> toggleLike() async {
    if (video == null || backendUrl == null) return;

    final prevLiked = isLiked;
    final prevCount = likeCount;

    setState(() {
      isLiked = !prevLiked;
      likeCount = prevLiked ? (prevCount - 1) : (prevCount + 1);
    });

    try {
      final token = await storage.read(key: "token");
      final res = await http.post(
        Uri.parse("${backendUrl!}/app/videos/${video!['_id']}/like"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode != 200) {
        setState(() {
          isLiked = prevLiked;
          likeCount = prevCount;
        });
        debugPrint("Failed to like: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      setState(() {
        isLiked = prevLiked;
        likeCount = prevCount;
      });
      debugPrint("Error liking video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (video == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uploader = (video!['uploader'] as Map?) ?? {};
    final String avatarUrl = uploader['avatarUrl'] != null
        ? _buildPlayableUrl('${backendUrl ?? ''}${uploader['avatarUrl']}')
        : _buildPlayableUrl('${backendUrl ?? ''}/BeFab.png');

    final title = (video!['title'] as String?) ?? 'Fitness New';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SvgPicture.asset(
                  'assets/images/Arrow2.svg',
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Builder(
              builder: (context) {
                if (_hasError) {
                  return _ErrorView(
                    message: _errorMsg ?? 'Could not play this video.',
                    onRetry: () async {
                      if (!mounted) return;
                      final url = _buildPlayableUrl(
                          '${backendUrl ?? ''}${video!['url'] ?? ''}');
                      await _initController(url);
                    },
                  );
                }

                if (!_isReady || _controller == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final aspect = _controller!.value.aspectRatio == 0
                        ? 16 / 9
                        : _controller!.value.aspectRatio;
                    final width = constraints.maxWidth;
                    final height = width / aspect;

                    return Center(
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: VideoPlayer(_controller!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            right: 16,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 24,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 11), // adjust as needed
        child: SizedBox(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 3),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
