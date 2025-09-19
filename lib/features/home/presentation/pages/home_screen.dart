import 'package:flutter/material.dart';
import 'package:telegram_story_appbar/features/home/data/models/user_model.dart';
import 'package:telegram_story_appbar/features/home/presentation/pages/story_screen.dart';
import 'package:telegram_story_appbar/features/home/presentation/widgets/appbar_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  final users = [
  UserModel(
    userName: 'Martin Randolph',
    userImage: 'assets/images/image6.png',
    stories: [
      'assets/images/story1.jpg',
      'assets/images/story2.jpg',
      'assets/images/story3.jpg',
    ],
  ),
  UserModel(
    userName: 'Karen Castillo',
    userImage: 'assets/images/image5.png',
    stories: [
      'assets/images/story4.jpg',
      'assets/images/story5.jpg',
    ],
  ),
  UserModel(
    userName: 'Kieron Dotson',
    userImage: 'assets/images/image4.png',
    stories: [
      'assets/images/story6.jpg',
    ],
  ),
  UserModel(
    userName: 'Zack John',
    userImage: 'assets/images/image3.png',
    stories: [
      'assets/images/story7.jpg',
    ],
  ),
  UserModel(
    userName: 'Jamie Franco',
    userImage: 'assets/images/image2.png',
    stories: [
      'assets/images/story8.jpg',
    ],
  ),
  UserModel(
    userName: 'Martha Craig',
    userImage: 'assets/images/image1.png',
    stories: [
      'assets/images/story9.jpg',
    ],
  ),
];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        AppBarItem(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                            pageBuilder: (_, __, ___) =>
                                StoryScreen(
                                  users: users,
                                  initialUserIndex: index),
                          ),
                        );
                      },
                      user: users[index],
                    ),
                        Text(users[index].userName,overflow: TextOverflow.ellipsis,)
                      ],
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
