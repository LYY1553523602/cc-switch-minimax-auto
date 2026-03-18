/// 链接提取服务
class LinkExtractorService {
  /// 从文本中提取小红书链接
  static List<String> extractXiaohongshuLinks(String text) {
    if (text.isEmpty) return [];

    List<String> links = [];

    // 主域名链接
    final mainRegex = RegExp(
      r'https?://(?:www\.)?xiaohongshu\.com/(?:explore|discovery/item|user/profile)/[^\s]+',
    );
    links.addAll(mainRegex.allMatches(text).map((m) => m.group(0)!));

    // 短链接
    final shortRegex = RegExp(r'https?://xhslink\.com/[^\s]+');
    links.addAll(shortRegex.allMatches(text).map((m) => m.group(0)!));

    // 去重并清理
    links = links.map((link) => link.replaceAll(RegExp(r'["\')]>+$'), '')).toList();
    links = links.toSet().toList();

    return links;
  }

  /// 验证链接是否有效
  static bool isValidLink(String link) {
    return link.contains('xiaohongshu.com') || link.contains('xhslink.com');
  }

  /// 清理链接，移除跟踪参数
  static String cleanLink(String link) {
    final paramsToRemove = ['utm_source', 'utm_medium', 'utm_campaign', 'share_token'];
    var url = link.split('?')[0];
    return url;
  }
}
