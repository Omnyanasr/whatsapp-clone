class StoryModel {
  final String id;
  final String userName;
  final String avatarUrl;
  final List<String> mediaUrls; // images only for simplicity
  final DateTime postedAt;

  StoryModel({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.mediaUrls,
    required this.postedAt,
  });
}
