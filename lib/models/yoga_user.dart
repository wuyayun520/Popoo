class YogaUser {
  final String userId;
  final String name;
  final String profilePicture;
  final String profilePictureBg;
  final String userIcon;
  final String introduction;
  final String signature;
  final String tag;
  final List<YogaPost> posts;

  YogaUser({
    required this.userId,
    required this.name,
    required this.profilePicture,
    required this.profilePictureBg,
    required this.userIcon,
    required this.introduction,
    required this.signature,
    required this.tag,
    required this.posts,
  });

  factory YogaUser.fromJson(Map<String, dynamic> json) {
    return YogaUser(
      userId: json['userId'] as String,
      name: json['name'] as String,
      profilePicture: json['profilepicture'] as String,
      profilePictureBg: json['profilepictureBg'] as String,
      userIcon: json['userIcon'] as String,
      introduction: json['introduction'] as String,
      signature: json['signature'] as String,
      tag: json['tag'] as String,
      posts: (json['post'] as List)
          .map((post) => YogaPost.fromJson(post))
          .toList(),
    );
  }
}

class YogaPost {
  final String postId;
  final String message;
  final String videoUrl;

  YogaPost({
    required this.postId,
    required this.message,
    required this.videoUrl,
  });

  factory YogaPost.fromJson(Map<String, dynamic> json) {
    return YogaPost(
      postId: json['postId'] as String,
      message: json['message'] as String,
      videoUrl: json['videoUrl'] as String,
    );
  }
} 