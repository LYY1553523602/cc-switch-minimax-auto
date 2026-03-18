/// 抓取结果模型
class CrawlResult {
  final String link;
  final String? author;
  final String? title;
  final int like;
  final int collect;
  final int comment;
  final int forward;
  final int followers;
  final String status;

  CrawlResult({
    required this.link,
    this.author,
    this.title,
    required this.like,
    required this.collect,
    required this.comment,
    required this.forward,
    required this.followers,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'author': author,
      'title': title,
      'like': like,
      'collect': collect,
      'comment': comment,
      'forward': forward,
      'followers': followers,
      'status': status,
    };
  }

  /// 格式化输出
  String formatOutput() {
    String followersText = _formatFollowers(followers);
    return '【转发:$forward 评论:$comment 点赞:$like】（粉丝量：$followersText）';
  }

  String _formatFollowers(int num) {
    if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}万';
    }
    return num.toString();
  }
}
