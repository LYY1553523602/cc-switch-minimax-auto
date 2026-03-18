import 'package:flutter/services.dart';
import '../models/crawl_result.dart';
import 'link_extractor_service.dart';

/// 爬虫服务 - 与原生Android交互
class CrawlService {
  static const platform = MethodChannel('com.ccswitch.minimax/crawl');

  /// 开始爬取
  static Future<CrawlResult> crawlSingleLink(String link) async {
    try {
      // 调用原生方法
      final result = await platform.invokeMethod('crawlLink', {'link': link});

      return CrawlResult(
        link: link,
        author: result['author'] ?? '',
        title: result['title'] ?? '',
        like: result['like'] ?? 0,
        collect: result['collect'] ?? 0,
        comment: result['comment'] ?? 0,
        forward: result['forward'] ?? 0,
        followers: result['followers'] ?? 0,
        status: result['status'] ?? 'success',
      );
    } on PlatformException catch (e) {
      return CrawlResult(
        link: link,
        like: 0,
        collect: 0,
        comment: 0,
        forward: 0,
        followers: 0,
        status: 'error: ${e.message}',
      );
    }
  }

  /// 批量爬取
  static Stream<CrawlResult> crawlMultipleLinks(List<String> links) async* {
    for (var link in links) {
      yield await crawlSingleLink(link);
      // 随机等待，避免频繁操作
      await Future.delayed(Duration(milliseconds: 1000 + (2000 * (DateTime.now().millisecond / 1000)).toInt()));
    }
  }
}
