import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/yoga_user.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailPage extends StatefulWidget {
  final YogaUser user;
  const UserDetailPage({super.key, required this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadBlockStatus();
  }

  Future<void> _loadBlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'blocked_${widget.user.userId}';
    final value = prefs.getBool(key) ?? false;
    print('loadBlockStatus: key=$key, value=$value');
    setState(() {
      _isBlocked = value;
    });
  }

  Future<void> _setBlockStatus(bool blocked) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'blocked_${widget.user.userId}';
    await prefs.setBool(key, blocked);
    print('setBlockStatus: key=$key, value=$blocked');
    setState(() {
      _isBlocked = blocked;
      print('setState: _isBlocked=$_isBlocked');
    });
  }

  void _showMoreActions() {
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isBlocked)
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Block User', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    print('点击了Block User ListTile');
                    Navigator.pop(context);
                    final confirmed = await showDialog<bool>(
                      context: parentContext,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Block User'),
                        content: const Text('Are you sure you want to block this user?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Block'),
                          ),
                        ],
                      ),
                    );
                    print('Block User弹窗返回: $confirmed, context.mounted=${parentContext.mounted}');
                    if (confirmed == true && parentContext.mounted) {
                      print('准备执行_setBlockStatus(true)');
                      await _setBlockStatus(true);
                      print('已执行_setBlockStatus(true)');
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('User has been blocked.'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              if (_isBlocked)
                ListTile(
                  leading: const Icon(Icons.lock_open, color: Colors.green),
                  title: const Text('Unblock User', style: TextStyle(color: Colors.green)),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await showDialog<bool>(
                      context: parentContext,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Unblock User'),
                        content: const Text('Do you want to unblock this user?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Unblock'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && parentContext.mounted) {
                      await _setBlockStatus(false);
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('User has been unblocked.'), backgroundColor: Colors.green),
                      );
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: const Text('Report User', style: TextStyle(color: Colors.orange)),
                onTap: () async {
                  Navigator.pop(context);
                  final reasons = [
                    'Spam',
                    'Inappropriate Content',
                    'Harassment',
                    'Other',
                  ];
                  String? selectedReason;
                  final confirmed = await showDialog<bool>(
                    context: parentContext,
                    builder: (ctx) => StatefulBuilder(
                      builder: (ctx, setState) => AlertDialog(
                        title: const Text('Report User'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...reasons.map((reason) => RadioListTile<String>(
                                  title: Text(reason),
                                  value: reason,
                                  groupValue: selectedReason,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedReason = val;
                                    });
                                  },
                                )),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: selectedReason == null
                                ? null
                                : () => Navigator.pop(ctx, true),
                            child: const Text('Report'),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (confirmed == true && parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Report submitted successfully.'), backgroundColor: Colors.orange),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreActions,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 顶部背景+用户信息浮层
          Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.user.userIcon,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.white,
                      ],
                      stops: [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage(widget.user.profilePicture),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.user.introduction,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6D6D6D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.user.signature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFA68FF4),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: widget.user.tag.split(',').map((tag) => Chip(
                              label: Text(tag.trim()),
                              backgroundColor: const Color(0xFFE7DEFB),
                              labelStyle: const TextStyle(color: Color(0xFFA68FF4)),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),
                          if (_isBlocked)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'You have blocked this user.',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          if (!_isBlocked)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA68FF4),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(user: widget.user),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Works',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA68FF4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...widget.user.posts.map((post) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _VideoCard(
              videoUrl: post.videoUrl,
              title: post.message,
            ),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final String videoUrl;
  final String title;
  const _VideoCard({required this.videoUrl, required this.title});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: _initialized
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        if (!_controller.value.isPlaying)
                          AnimatedOpacity(
                            opacity: !_controller.value.isPlaying ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white.withOpacity(0.8),
                              size: 56,
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(
                    color: const Color(0xFFE7DEFB),
                    height: 180,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 