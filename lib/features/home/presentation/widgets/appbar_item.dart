import 'package:flutter/material.dart';
import 'package:telegram_story_appbar/features/home/data/models/user_model.dart';

class AppBarItem extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const AppBarItem({super.key, required this.user, this.onTap});

  @override
  State<AppBarItem> createState() => _AppBarItemState();
}

class _AppBarItemState extends State<AppBarItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(90),
      onTap: widget.onTap ?? () {},
      child: Hero(
        tag: 'story-${widget.user.userName}',
        child: 
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: widget.user.userImage != null && widget.user.userImage!.isNotEmpty
                ? Image.asset(
                    widget.user.userImage!,
                    fit: BoxFit.cover, 
                    width: 80,
                    height: 80,
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
