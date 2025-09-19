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
          // page viuve keyingi sahifagat otadi
          _pageController.animateToPage(
            _currentUserIndex,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
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
    _currentUserIndex--;
    _currentStoryIndex = widget.users[_currentUserIndex].stories!.length - 1;
    _pageController.animateToPage(
      _currentUserIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _startTimer();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onPanUpdate: (details) {
          Navigator.pop(context);
        },
        onPanDown: (_) {
          _pauseTimer();
        },
        onPanCancel: () {
          _resumeTimer();
        },
        onPanEnd: (_) {
          _resumeTimer();
        },
        child: PageView.builder(
          onPageChanged: (value) {
            setState(() {
              _currentUserIndex = value;
              _currentStoryIndex = 0;
              _startTimer();
            });
          },
          controller: _pageController,
          itemCount: widget.users.length,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final currentUser = widget.users[index];
            final totalStories = currentUser.stories!.length;
            final value = _pageController.hasClients
                ? (_pageController.page ?? _pageController.initialPage) - index
                : 0.0;

            final rotationY = value.clamp(-1, 1);
            final storyIndex = _currentStoryIndex.clamp(0, totalStories - 1);
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
                        currentUser.stories![storyIndex],
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
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
      ),
    );
  }
}
