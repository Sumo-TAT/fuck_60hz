#!/system/bin/sh
# Fuck 60Hz - 究极绝对死锁安全版

# 1. 开机双重安全延迟（防 Bootloop 锁死）
sleep 15
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 3; done
while [ -z "$(settings get system screen_refresh_rate 2>/dev/null)" ]; do sleep 3; done
sleep 5

# ==================== 铁腕锁死逻辑开始 ====================

# 2. 物理分辨率与帧率硬死锁 (WindowManager 级别)
# 直接用窗口管理器把物理显示的天花板和地板全部焊死在 120
wm refresh-rate 120.0 2>/dev/null

# 进入地毯式、高频洗脑循环
while true; do
    # 3. 剥离图形渲染器 (SurfaceFlinger) 的温控与低电量限速
    # 强制让渲染器只认 120Hz
    service call SurfaceFlinger 1035 i32 1 >/dev/null 2>&1  # 针对部分老机型的渲染器锁定
    
    # 4. 暴力注入显示系统 (Display Service)
    # 强行下发 Mode ID 2（通常是 120Hz 的物理显示硬编码）
    service call display 1 i32 2 >/dev/null 2>&1
    service call display 5 i32 2 >/dev/null 2>&1 # 某些魔改类原生系统的备用 display 通道
    
    # 5. 封死 Settings 数据库中的全量刷新率参数
    settings put system min_refresh_rate 120.0
    settings put system peak_refresh_rate 120.0
    settings put system screen_refresh_rate 120
    
    # 6. 碾碎低电量省电模式的触发几率
    settings put global low_power_trigger_level 0
    settings put global low_power 0 # 强行关闭已经触发的省电模式状态
    
    # 7. 极致对抗：每隔 1.5 秒暴力洗脑一次
    sleep 1.5
done
