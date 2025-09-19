import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:telegram_story_appbar/features/home/data/models/user_model.dart';

class StoryScreen extends StatefulWidget {
  final List<UserModel> users;
  final int initialUserIndex;
  const StoryScreen({
    super.key,
    required this.initialUserIndex,
    required this.users,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  bool _isContentVisible = false;
  double _progress = 0.0;
  Timer? _timer;
  int _currentStoryIndex = 0;
  int _currentUserIndex = 0;
  bool _isPaused = false;
  UserModel get currentUser => widget.users[_currentUserIndex];
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: widget.initialUserIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _isContentVisible = true;
          });
        }
      });
    });
    _startTimer();
  }

  @override
  void dispose() {
    _progress = 0;
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPaused) return;

      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _goToNextStory();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  void _goToNextStory() {
    if (_currentStoryIndex < currentUser.stories!.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _startTimer();
      });
    } else {
      if (_currentUserIndex < widget.users.length - 1) {
        setState(() {
          _currentUserIndex++;
          _currentStoryIndex = 0;
          _startTimer();
        });
      } else {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }
  }

  void _goToPreviousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _startTimer();
      });
    } else if (_currentUserIndex > 0) {
      setState(() {
        _currentUserIndex--;
        _currentStoryIndex = currentUser.stories!.length - 1;
        _startTimer();
      });
    }
  }

  void _goToNextUser() {
    if (_currentUserIndex < widget.users.length - 1) {
      setState(() {
        _currentUserIndex++;
        _currentStoryIndex = 0;
        _startTimer();
      });
    } else {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // ✅ oxirgi userdan keyin chiqish
      }
    }
  }

  void _goToPreviousUser() {
    if (_currentUserIndex > 0) {
      setState(() {
        _currentUserIndex--;
        _currentStoryIndex = currentUser.stories!.length - 1;
        _startTimer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStories = currentUser.stories!.length;
    log('_isPaused: $_isPaused');
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.users.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final currentUser = widget.users[index];
          final value = _pageController.hasClients
              ? (_pageController.page ?? _pageController.initialPage) - index
              : 0.0;

          final rotationY = value.clamp(-1, 1);

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotationY.toDouble()),
            alignment: Alignment.center,
            child: Hero(
              tag: 'story-${currentUser.userName}',
              child: Stack(
                children: [
                  // storeys
                  Positioned.fill(
                    child: Image.asset(
                      currentUser.stories![_currentStoryIndex],
                      fit: BoxFit.cover,
                    ),
                  ),

                  // linerProgres
                  Positioned(
                    top: 40,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: List.generate(totalStories, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: LinearProgressIndicator(
                              value: index == _currentStoryIndex
                                  ? _progress
                                  : (index < _currentStoryIndex ? 1.0 : 0.0),
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ekran bosilganda va ahrakatga qarab scrool qialdi
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPressStart: (details) {
                      _pauseTimer();
                    },
                    onLongPressEnd: (_) {
                      _resumeTimer();
                    },
                    onTapDown: (details) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      if (details.globalPosition.dx < screenWidth / 2) {
                        _goToPreviousUser();
                      } else {
                        _goToNextUser();
                      }
                    },
                    child: Container(),
                  ),

                  // user info
                  SafeArea(
                    child: AnimatedOpacity(
                      opacity: _isContentVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                // userAvatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      currentUser.userImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // username
                                Text(
                                  currentUser.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // back
                  Positioned(
                    left: 10,
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: _goToPreviousStory,
                    ),
                  ),

                  // next
                  Positioned(
                    right: 10,
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      onPressed: _goToNextStory,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
