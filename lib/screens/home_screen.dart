import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crawl_result.dart';
import '../services/link_extractor_service.dart';
import '../services/crawl_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _links = [];
  List<CrawlResult> _results = [];
  bool _isRunning = false;
  int _currentIndex = 0;

  /// 从剪贴板提取链接
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      final links = LinkExtractorService.extractXiaohongshuLinks(clipboardData!.text!);
      setState(() {
        _links = links.toSet().toList(); // 去重
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已提取 ${_links.length} 个链接')),
      );
    }
  }

  /// 开始抓取
  Future<void> _startCrawl() async {
    if (_links.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先粘贴链接')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _results = [];
      _currentIndex = 0;
    });

    for (var link in _links) {
      if (!_isRunning) break;

      final result = await CrawlService.crawlSingleLink(link);
      setState(() {
        _results.add(result);
        _currentIndex++;
      });
    }

    setState(() {
      _isRunning = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('抓取完成！共 ${_results.length} 条')),
      );
    }
  }

  /// 停止抓取
  void _stopCrawl() {
    setState(() {
      _isRunning = false;
    });
  }

  /// 复制结果
  Future<void> _copyResults() async {
    if (_results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无结果')),
      );
      return;
    }

    final output = _results.map((r) => r.formatOutput()).join('\n');
    await Clipboard.setData(ClipboardData(text: output));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小红书数据抓取'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 粘贴按钮
            ElevatedButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.content_paste),
              label: const Text('粘贴剪贴板链接'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red.shade50,
              ),
            ),

            const SizedBox(height: 8),

            // 链接数量
            Text(
              '当前链接数：${_links.length}',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 8),

            // 链接列表
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.link, size: 16),
                      title: Text(
                        _links[index],
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _startCrawl,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始抓取'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? _stopCrawl : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 进度显示
            if (_isRunning)
              Text(
                '正在抓取 $_currentIndex/${_links.length}',
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 8),

            // 结果列表
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red.shade100,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        _results[index].formatOutput(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 复制按钮
            ElevatedButton.icon(
              onPressed: _copyResults,
              icon: const Icon(Icons.copy),
              label: const Text('一键复制结果'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
