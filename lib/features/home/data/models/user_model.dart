class UserModel {
  final String userName;
  final String? userImage;
  final List<String>? stories;

  UserModel({
    required this.userName,
    this.userImage,
    this.stories,
  });
}

