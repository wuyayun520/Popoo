import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/yoga_user.dart';

class VideoCallPage extends StatefulWidget {
  final YogaUser user;
  const VideoCallPage({super.key, required this.user});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  int _timer = 20;
  late final String _videoUrl;
  bool _isHangedUp = false;

  @override
  void initState() {
    super.initState();
    // 取第一个作品视频作为背景
    final posts = widget.user.posts;
    _videoUrl = posts.isNotEmpty ? posts[0].videoUrl : '';
    _controller = VideoPlayerController.asset(_videoUrl)
      ..initialize().then((_) {
        if (mounted && !_isHangedUp) {
          setState(() {
            _initialized = true;
            _controller.setLooping(true);
            _controller.play();
          });
        }
      });
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!mounted || _isHangedUp || _timer <= 0) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _isHangedUp) return false;
      setState(() {
        _timer--;
      });
      if (_timer == 0 && !_isHangedUp) {
        _hangup(auto: true);
      }
      return _timer > 0 && !_isHangedUp;
    });
  }

  void _hangup({bool auto = false}) {
    if (_isHangedUp) return;
    _isHangedUp = true;
    if (mounted) {
      Navigator.pop(context);
      if (auto) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User is not online.'), backgroundColor: Colors.red),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _isHangedUp = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景视频
          if (_initialized)
            Positioned.fill(
              child: _controller.value.isInitialized
                  ? VideoPlayerFullScreen(controller: _controller)
                  : Container(color: Colors.black),
            ),
          // 半透明遮罩
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          // 内容
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(widget.user.profilePicture),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.user.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Calling... ($_timer s)',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    icon: const Icon(Icons.call_end),
                    label: const Text('Hang up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () => _hangup(auto: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerFullScreen extends StatelessWidget {
  final VideoPlayerController controller;
  const VideoPlayerFullScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
} 