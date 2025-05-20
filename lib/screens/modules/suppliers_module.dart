import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:video_player/video_player.dart';
import '../../models/yoga_user.dart';
import 'dart:async';

class SuppliersModule extends StatefulWidget {
  const SuppliersModule({super.key});

  @override
  State<SuppliersModule> createState() => _SuppliersModuleState();
}

class _SuppliersModuleState extends State<SuppliersModule> {
  List<YogaUser> _users = [];
  List<_Course> _allCourses = [];
  bool _loading = true;
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  List<_Course> _randomCourses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonString = await rootBundle.loadString('assets/jsondata/brepeople.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> usersJson = jsonData['allData'];
    final users = usersJson.map((json) => YogaUser.fromJson(json)).toList();
    final List<_Course> allCourses = [];
    for (final user in users) {
      for (final post in user.posts) {
        allCourses.add(_Course(
          user: user,
          title: post.message,
          videoUrl: post.videoUrl,
          cover: user.profilePictureBg,
          rating: 4 + Random().nextInt(2), // 4~5星
        ));
      }
    }
    setState(() {
      _users = users;
      _allCourses = allCourses;
      _loading = false;
      _randomCourses = _pickRandomCourses(allCourses, 3);
    });
  }

  List<_Course> _pickRandomCourses(List<_Course> list, int count) {
    final rand = Random();
    final copy = List<_Course>.from(list);
    copy.shuffle(rand);
    return copy.take(count).toList();
  }

  void _showVideo(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            _VideoPlayerInline(videoUrl: videoUrl),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 0, right: 0, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Popular Courses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _StackedDraggableCards(
              courses: _allCourses.take(10).toList(),
              onPlay: (videoUrl) => _showVideo(context, videoUrl),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Courses for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _randomCourses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final course = _randomCourses[index];
                  return GestureDetector(
                    onTap: () => _showVideo(context, course.videoUrl),
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                            child: Stack(
                              children: [
                                Image.asset(
                                  course.cover,
                                  width: 120,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Text(
                              course.title.split(' ').take(3).join(' '),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: List.generate(5, (i) => Icon(
                                i < course.rating ? Icons.star : Icons.star_border,
                                color: const Color(0xFFFFB800),
                                size: 18,
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Course {
  final YogaUser user;
  final String title;
  final String videoUrl;
  final String cover;
  final int rating;
  _Course({required this.user, required this.title, required this.videoUrl, required this.cover, required this.rating});
}

class _VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerDialog({required this.videoUrl});

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play();
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
    return _initialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (!_controller.value.isPlaying)
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
                  onPressed: () => setState(() => _controller.play()),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class _StackedDraggableCards extends StatefulWidget {
  final List<_Course> courses;
  final void Function(String videoUrl) onPlay;
  const _StackedDraggableCards({required this.courses, required this.onPlay});

  @override
  State<_StackedDraggableCards> createState() => _StackedDraggableCardsState();
}

class _StackedDraggableCardsState extends State<_StackedDraggableCards> {
  late List<_Course> _cardStack;
  double _dragDx = 0;
  bool _isPlaying = false;
  String? _playingVideoUrl;

  @override
  void initState() {
    super.initState();
    _cardStack = List<_Course>.from(widget.courses.take(10));
  }

  void _onPlay(String videoUrl) {
    setState(() {
      _isPlaying = true;
      _playingVideoUrl = videoUrl;
    });
  }

  void _onCloseVideo() {
    setState(() {
      _isPlaying = false;
      _playingVideoUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width - 20;
    const cardHeight = 400.0;
    final total = _cardStack.length;
    return SizedBox(
      height: cardHeight + 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(total, (i) {
          final layer = i;
          final scale = 1 - 0.05 * (total - 1 - layer);
          final offset = 16.0 * (total - 1 - layer);
          final isTop = layer == total - 1;
          final course = _cardStack[layer];
          return Positioned(
            top: offset,
            left: offset,
            right: offset,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: isTop
                  ? GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _dragDx += details.delta.dx;
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_dragDx.abs() > cardWidth * 0.25) {
                          setState(() {
                            _dragDx = 0;
                            _isPlaying = false;
                            _playingVideoUrl = null;
                            if (_cardStack.length > 1) {
                              _cardStack.removeLast();
                            }
                          });
                        } else {
                          setState(() {
                            _dragDx = 0;
                          });
                        }
                      },
                      child: Transform.translate(
                        offset: Offset(_dragDx, 0),
                        child: _CourseCard(
                          course: course,
                          width: cardWidth,
                          height: cardHeight,
                          isPlaying: _isPlaying,
                          videoUrl: _playingVideoUrl,
                          onPlay: () => _onPlay(course.videoUrl),
                          onCloseVideo: _onCloseVideo,
                        ),
                      ),
                    )
                  : _CourseCard(
                      course: course,
                      width: cardWidth,
                      height: cardHeight,
                      isPlaying: false,
                      videoUrl: null,
                      onPlay: null,
                      onCloseVideo: null,
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final _Course course;
  final double width;
  final double height;
  final bool isPlaying;
  final String? videoUrl;
  final VoidCallback? onPlay;
  final VoidCallback? onCloseVideo;
  const _CourseCard({required this.course, required this.width, required this.height, required this.isPlaying, this.videoUrl, this.onPlay, this.onCloseVideo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isPlaying && videoUrl != null
            ? Stack(
                children: [
                  _VideoPlayerInline(videoUrl: videoUrl!),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onCloseVideo,
                    ),
                  ),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    course.cover,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                  GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _VideoPlayerInline extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerInline({required this.videoUrl});

  @override
  State<_VideoPlayerInline> createState() => _VideoPlayerInlineState();
}

class _VideoPlayerInlineState extends State<_VideoPlayerInline> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _showControlsTemporarily,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          if (_showControls)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (context, VideoPlayerValue value, child) {
                            return Text(
                              '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return SliderTheme(
                        data: SliderThemeData(
                          thumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: value.position.inMilliseconds.toDouble(),
                          min: 0,
                          max: value.duration.inMilliseconds.toDouble(),
                          onChanged: (newValue) {
                            _controller.seekTo(Duration(milliseconds: newValue.toInt()));
                          },
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.setVolume(_controller.value.volume > 0 ? 0 : 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!_controller.value.isPlaying && !_showControls)
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
        ],
      ),
    );
  }
} 