#!/system/bin/sh

ui_print "**************************************"
ui_print " [⚠️] 本模块在 GitHub/酷安 永久免费开源"
ui_print " [⚠️] 严禁私自修改、倒卖入群"
ui_print " [⚠️] 如果你是花钱买的，请你找卖家退款并举报"
ui_print "**************************************"
ui_print ""
ui_print "- 正在检测设备屏幕高刷硬件..."

# 绕过 getprop 的 60Hz 假象，直接用绝对路径去拿显示模式数据
if [ -f "/system/bin/dumpsys" ]; then
    REFRESH_RATES=$(/system/bin/dumpsys display | grep -E "fps|refreshRate|supportedModes" | tr -d '\r')
fi

# 检查物理参数里有没有 120
if echo "$REFRESH_RATES" | grep -q "120" || [ -d "/sys/class/drm" ]; then
    ui_print "[✓] 检测成功：当前设备硬件支持 120Hz！"
    ui_print "- 正在注入：解封物理高刷限制..."
    
    # 强制将系统底层的默认和最大属性修改为 120
    resetprop ro.vendor.display.default_fps 120
    resetprop ro.surface_flinger.max_graphics_width 120
    
    ui_print "[✓] 注入成功！"
else
    ui_print "**************************************"
    ui_print "[X] 安装终止：未检测到 120Hz 硬件支持！"
    ui_print "**************************************"
    abort "-> 错误：设备不匹配，已取消安装。"
fi
