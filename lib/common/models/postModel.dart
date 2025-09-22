class PostModel {
  final int id;
  final DateTime createdAt;
  final String clubName;
  final String? clubId;
  final String title;
  final String description;
  final String createdBy;

  PostModel({
    required this.id,
    required this.createdAt,
    required this.clubName,
    required this.title,
    required this.description,
    required this.createdBy,
    this.clubId
  });

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    }
  }

  String get formattedCreatedAt {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year.toString();
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '[$day/$month/$year]\n[$hour:$minute]';
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      clubName: json['club_name'],
      clubId: json['clubId'],
      title: json['title'],
      description: json['description'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt,
      'club_name': clubName,
      'clubId': clubId,
      'title': title,
      'description': description,
      'created_by': createdBy,
    };
  }
}
