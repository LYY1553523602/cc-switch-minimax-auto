package com.ccswitch.minimax

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.graphics.Rect
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class CrawlAccessibilityService : AccessibilityService() {

    companion object {
        const val TAG = "CrawlService"
        var instance: CrawlAccessibilityService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.d(TAG, "服务已连接")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // 处理无障碍事件
    }

    override fun onInterrupt() {
        Log.d(TAG, "服务中断")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    /**
     * 打开小红书链接
     */
    fun openXiaohongshuLink(link: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = android.net.Uri.parse(link)
                setPackage("com.xingin.xhs")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            Thread.sleep(3000) // 等待页面加载
            true
        } catch (e: Exception) {
            Log.e(TAG, "打开链接失败: ${e.message}")
            false
        }
    }

    /**
     * 识别页面基础数据（点赞、评论、收藏）
     */
    fun recognizeBasicData(): Map<String, Int> {
        val data = mutableMapOf(
            "like" to 0,
            "collect" to 0,
            "comment" to 0
        )

        try {
            val rootNode = rootInActiveWindow ?: return data

            // 查找底部工具栏的文本节点
            val textNodes = mutableListOf<AccessibilityNodeInfo>()
            findTextNodes(rootNode, textNodes)

            for (node in textNodes) {
                val text = node.text?.toString() ?: continue

                when {
                    text.contains("赞") -> {
                        // 获取附近的数字
                        data["like"] = extractNearbyNumber(node)
                    }
                    text.contains("收藏") -> {
                        data["collect"] = extractNearbyNumber(node)
                    }
                    text.contains("评论") -> {
                        data["comment"] = extractNearbyNumber(node)
                    }
                }
            }

            rootNode.recycle()
        } catch (e: Exception) {
            Log.e(TAG, "识别数据失败: ${e.message}")
        }

        return data
    }

    /**
     * 点击作者头像进入主页
     */
    fun clickAuthorAvatar(): Boolean {
        return try {
            val rootNode = rootInActiveWindow ?: return false

            // 尝试多种方式查找头像
            var clicked = false

            // 方法1：查找头像ImageView
            val avatarViews = rootNode.findViewsByText("")
            for (view in avatarViews) {
                if (isAvatarView(view)) {
                    clicked = view.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                    break
                }
            }

            // 方法2：通过坐标点击（屏幕左侧上方）
            if (!clicked) {
                val x = (resources.displayMetrics.widthPixels * 0.15).toInt()
                val y = (resources.displayMetrics.heightPixels * 0.15).toInt()
                clicked = performGlobalAction(GLOBAL_ACTION_CLICK)
            }

            Thread.sleep(2000)
            clicked
        } catch (e: Exception) {
            Log.e(TAG, "点击头像失败: ${e.message}")
            false
        }
    }

    /**
     * 识别粉丝数
     */
    fun recognizeFollowers(): Int {
        return try {
            val rootNode = rootInActiveWindow ?: return 0

            // 查找"粉丝"文字
            val fansNode = findTextNode(rootNode, "粉丝") ?: return 0

            // 在上方查找数字
            val number = extractNumberAboveNode(fansNode)
            fansNode.recycle()
            rootNode.recycle()

            number
        } catch (e: Exception) {
            Log.e(TAG, "识别粉丝失败: ${e.message}")
            0
        }
    }

    /**
     * 返回上一页
     */
    fun goBack(): Boolean {
        return performGlobalAction(GLOBAL_ACTION_BACK)
    }

    // 辅助方法
    private fun findTextNodes(node: AccessibilityNodeInfo, list: MutableList<AccessibilityNodeInfo>) {
        if (node.childCount == 0) {
            if (!node.text.isNullOrEmpty()) {
                list.add(node)
            }
        } else {
            for (i in 0 until node.childCount) {
                node.getChild(i)?.let { child ->
                    findTextNodes(child, list)
                    child.recycle()
                }
            }
        }
    }

    private fun findTextNode(node: AccessibilityNodeInfo, text: String): AccessibilityNodeInfo? {
        if (node.text?.toString()?.contains(text) == true) {
            return node
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            val result = findTextNode(child, text)
            child.recycle()
            if (result != null) return result
        }
        return null
    }

    private fun extractNearbyNumber(node: AccessibilityNodeInfo): Int {
        // 查找同层级附近的数字
        val parent = node.parent ?: return 0
        for (i in 0 until parent.childCount) {
            val child = parent.getChild(i) ?: continue
            val text = child.text?.toString()
            if (!text.isNullOrEmpty() && text.matches(Regex("^\\d+(\\.\\d+)?$"))) {
                val number = text.replace(",", "").toIntOrNull() ?: 0
                child.recycle()
                parent.recycle()
                return number
            }
            child.recycle()
        }
        parent.recycle()
        return 0
    }

    private fun extractNumberAboveNode(node: AccessibilityNodeInfo): Int {
        val bounds = Rect()
        node.getBoundsInScreen(bounds)

        val rootNode = rootInActiveWindow ?: return 0

        // 在上方区域查找数字
        val nodes = mutableListOf<AccessibilityNodeInfo>()
        findNodesInRect(rootNode, nodes, Rect(0, bounds.top - 100, resources.displayMetrics.widthPixels, bounds.top))

        for (n in nodes) {
            val text = n.text?.toString() ?: continue
            if (text.matches(Regex("^\\d+(\\.\\d+)?[万wW]?$"))) {
                val num = parseChineseNumber(text)
                n.recycle()
                rootNode.recycle()
                return num
            }
            n.recycle()
        }

        rootNode.recycle()
        return 0
    }

    private fun findNodesInRect(node: AccessibilityNodeInfo, list: MutableList<AccessibilityNodeInfo>, rect: Rect) {
        val bounds = Rect()
        if (!node.getBoundsInScreen(bounds)) return

        if (Rect.intersects(bounds, rect) && !node.text.isNullOrEmpty()) {
            list.add(node)
        }

        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { child ->
                findNodesInRect(child, list, rect)
                child.recycle()
            }
        }
    }

    private fun isAvatarView(node: AccessibilityNodeInfo): Boolean {
        // 判断是否为头像（通过大小、位置等特征）
        val bounds = Rect()
        node.getBoundsInScreen(bounds)
        val size = bounds.width()
        return size in 80..200 && bounds.left < resources.displayMetrics.widthPixels / 3
    }

    private fun parseChineseNumber(text: String): Int {
        val cleanText = text.replace(",", "").replace("万", "0000").replace("w", "0000").replace("W", "0000")
        return cleanText.toIntOrNull() ?: 0
    }
}
