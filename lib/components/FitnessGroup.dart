import 'dart:convert';
import 'package:befab/components/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// Full, self-contained FitnessGroupPage that:
/// - reads groupId from Navigator arguments: Navigator.pushNamed(context, '/fitness-group', arguments: {"id": "<groupId>"});
/// - fetches /app/groups/:id with Authorization header from secure storage
/// - maps all fields to UI (banner, avatar, name, description, visibility, members, posts)
/// - handles JOIN / LEAVE / REQUESTED transitions per spec

class FitnessGroupPage extends StatefulWidget {
  const FitnessGroupPage({super.key});

  @override
  State<FitnessGroupPage> createState() => _FitnessGroupPageState();
}

class _FitnessGroupPageState extends State<FitnessGroupPage> {
  final _storage = const FlutterSecureStorage();

  String? _groupId;
  Map<String, dynamic>? _group;
  List<dynamic> _posts = [];
  bool _loading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Defer until context is ready so we can read route arguments.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndFetch());
  }

  Future<void> _initAndFetch() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['id'] != null) {
      _groupId = args['id'].toString();
      await _fetchGroup();
    } else {
      setState(() {
        _loading = false;
      });
      _showSnack('Missing group id in route arguments.');
    }
  }

  // Build absolute URL from backend + relative path or pass-through absolute http(s)
  String _absUrl(String? path) {
    final base = dotenv.env['BACKEND_URL'] ?? '';
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    // ensure single slash join
    if (base.endsWith('/') && path.startsWith('/')) {
      return base + path.substring(1);
    } else if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return base + path;
  }

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchGroup() async {
    if (_groupId == null) return;
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse("${dotenv.env['BACKEND_URL']}/app/groups/$_groupId"),
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // backend could return { group: {...} } or just the object; handle both
        final g = (body is Map && body['group'] is Map)
            ? Map<String, dynamic>.from(body['group'])
            : Map<String, dynamic>.from(body);

        setState(() {
          _group = g;
          _posts = (g['posts'] is List) ? List.from(g['posts']) : <dynamic>[];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        _showSnack("Failed to fetch group: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => _loading = false);
      _showSnack("Error: $e");
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _handleJoinLeave() async {
    if (_group == null || _groupId == null) return;
    final String currentState = (_group!['state'] ?? 'JOIN').toString().toUpperCase();
    final String visibility = (_group!['visibility'] ?? 'public').toString().toLowerCase();

    // Decide endpoint: JOIN → join; LEAVE/REQUESTED → leave
    final String endpoint = (currentState == 'JOIN') ? 'join' : 'leave';

    try {
      final res = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/app/groups/$_groupId/$endpoint"),
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        // Update state per spec OR re-fetch for ground truth
        // Spec:
        // - If state was JOIN:
        //    - public → LEAVE
        //    - private → REQUESTED
        // - If state was LEAVE or REQUESTED → JOIN
        setState(() {
          if (currentState == 'JOIN') {
            _group!['state'] = (visibility == 'private') ? 'REQUESTED' : 'LEAVE';
          } else {
            _group!['state'] = 'JOIN';
          }
        });

        // Optionally re-fetch to sync other counters (members, requests etc.)
        await _fetchGroup();
      } else {
        _showSnack("Failed to update membership: ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  // ---- Helpers to safely read post fields (since backend shapes vary) ----

  String _postText(dynamic post) {
    if (post is Map) {
      return (post['content'] ??
              post['text'] ??
              post['caption'] ??
              '')
          .toString();
    }
    return '';
  }

  String? _postImage(dynamic post) {
    if (post is Map) {
      final img = post['imageUrl'] ??
          post['image'] ??
          post['mediaUrl'] ??
          (post['images'] is List && post['images'].isNotEmpty ? post['images'][0] : null) ??
          post['photo'];
      final s = img?.toString();
      if (s == null || s.isEmpty) return null;
      return _absUrl(s);
    }
    return null;
  }

  String _authorName(dynamic post) {
    if (post is Map) {
      final a = post['author'] ?? post['user'] ?? post['createdBy'];
      if (a is Map) return (a['name'] ?? a['username'] ?? 'Member').toString();
      if (a is String) return a; // fallback id string
    }
    return 'Member';
  }

  String? _authorAvatar(dynamic post) {
    if (post is Map) {
      final a = post['author'] ?? post['user'] ?? post['createdBy'];
      String? url;
      if (a is Map) {
        url = (a['avatar'] ?? a['imageUrl'] ?? a['photo'])?.toString();
      }
      if (url != null && url.isNotEmpty) return _absUrl(url);
    }
    return null;
  }

  String _createdAt(dynamic post) {
    if (post is Map) return (post['createdAt'] ?? '').toString();
    return '';
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Failed to load group')),
      );
    }

    final name = (_group!['name'] ?? '').toString();
    final description = (_group!['description'] ?? '').toString();
    final visibility = (_group!['visibility'] ?? 'public').toString().toLowerCase();
    final members = (_group!['members'] is List) ? (_group!['members'] as List) : const <dynamic>[];
    final state = (_group!['state'] ?? 'JOIN').toString().toUpperCase();

    final bannerUrl = _absUrl((_group!['bannerUrl'] ?? '').toString());
    final avatarUrl = _absUrl((_group!['imageUrl'] ?? '').toString());

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text('Groups', style: TextStyle(color: Colors.black, fontSize: 16)),
        actions: const [],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner + Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: (bannerUrl.isNotEmpty)
                          ? NetworkImage(bannerUrl)
                          : const AssetImage('assets/images/news_banner1.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -45,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: (avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : const AssetImage("assets/images/cat.png") as ImageProvider,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 55),

            // Group details + join button
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/globe.svg", color: const Color(0xFF5E6B87)),
                            const SizedBox(width: 4),
                            Text(
                              '${visibility[0].toUpperCase()}${visibility.substring(1)} group',
                              style: const TextStyle(color: Color(0xFF5E6B87), fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${members.length} Members',
                          style: const TextStyle(color: Color(0xFF5E6B87), fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  // JOIN / LEAVE / REQUESTED button
                  ElevatedButton(
                    onPressed: _handleJoinLeave, // REQUESTED also calls leave to cancel
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF862633),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    ),
                    child: Text(state), // will be JOIN / LEAVE / REQUESTED
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF5E6B87), height: 1.4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(),
            ),

            // Stats (demo values; wire real counts if backend provides)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('${_posts.length}', 'Posts'),
                  _buildStatItem('${members.length}', 'Members'),
                  _buildStatItem('${_posts.where((p) => _postImage(p) != null).length}', 'Photos'),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
              ),
              child: Row(
                children: [
                  _buildTabItem('Posts', 0),
                  _buildTabItem('Photos', 1),
                  _buildTabItem('Members', 2),
                  _buildTabItem('Events', 3),
                ],
              ),
            ),

            // Tab content
            SizedBox(
              height: 420,
              child: _buildTabContent(members),
            ),
          ],
        ),
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
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF862633) : const Color(0xFFBABABA),
                width: 1,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF862633) : const Color(0xFF5E6B87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(List members) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPostsTab();
      case 1:
        return _buildPhotosTab();
      case 2:
        return _buildMembersTab(members);
      case 3:
        return _buildEventsTab();
      default:
        return _buildPostsTab();
    }
  }

  // POSTS
  Widget _buildPostsTab() {
    if (_posts.isEmpty) {
      return const Center(child: Text('No posts yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final p = _posts[index];
        final text = _postText(p);
        final img = _postImage(p);
        final authorName = _authorName(p);
        final authorAvatar = _authorAvatar(p);
        final time = _createdAt(p);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.transparent,
                    backgroundImage: (authorAvatar != null && authorAvatar.isNotEmpty)
                        ? NetworkImage(authorAvatar)
                        : const AssetImage('assets/images/dog.png') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF5E6B87))),
                            const SizedBox(width: 4),
                            const Icon(Icons.public, size: 16, color: Color(0xFF5E6B87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (text.isNotEmpty)
                Text(
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87, height: 1.4),
                ),
              if (img != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(img, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // PHOTOS (extracted from posts)
  Widget _buildPhotosTab() {
    final photos = _posts
        .map((p) => _postImage(p))
        .where((u) => u != null && u!.isNotEmpty)
        .cast<String>()
        .toList();

    if (photos.isEmpty) {
      return const Center(child: Text('No photos yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(photos[i], fit: BoxFit.cover),
      ),
    );
  }

  // MEMBERS
  Widget _buildMembersTab(List members) {
    if (members.isEmpty) {
      return const Center(child: Text('No members yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final m = members[index];
        String title;
        String? avatar;

        if (m is Map) {
          title = (m['name'] ?? m['username'] ?? m['_id'] ?? 'Member').toString();
          final a = (m['avatar'] ?? m['imageUrl'] ?? m['photo'])?.toString();
          avatar = (a != null && a.isNotEmpty) ? _absUrl(a) : null;
        } else {
          title = m.toString();
          avatar = null;
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (avatar != null)
                ? NetworkImage(avatar)
                : const AssetImage('assets/images/dog.png') as ImageProvider,
          ),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
    );
  }

  // EVENTS (placeholder mapping if backend sends events[]; otherwise empty state)
  Widget _buildEventsTab() {
    final events = (_group?['events'] is List) ? List.from(_group!['events']) : const <dynamic>[];
    if (events.isEmpty) {
      return const Center(child: Text('No events yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final e = events[index] as Map? ?? {};
        final title = (e['title'] ?? 'Event').toString();
        final date = (e['date'] ?? e['when'] ?? '').toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF862633),
              child: const Icon(Icons.event, color: Colors.white),
            ),
            title: Text(title),
            subtitle: Text(date),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }
}
