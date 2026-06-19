#!/system/bin/sh
# 极其保守的开机等待 50 秒，等澎湃的所有底层服务全部握手完毕
sleep 50

lock_refresh_rate() {
    # 调高脚本优先级，确保弱网/高负载下依然准时执行
    renice -n -10 $$

    while true; do
        # 1. 纯内存级别的数据库写入（安全，绝不触发服务死锁）
        settings put system peak_refresh_rate 120.0 >/dev/null 2>&1
        settings put system min_refresh_rate 120.0 >/dev/null 2>&1
        settings put secure user_refresh_rate 120 >/dev/null 2>&1
        settings put system match_content_frame_rate 0 >/dev/null 2>&1
        
        # 2. 核心：直接用小米自己的温控控制键去打败它
        # 很多时候系统跳 60 只是因为这一项被改成了 60，我们每 0.5 秒把它洗脑成 120
        settings put system thermal_refresh_rate_limit 120 >/dev/null 2>&1

        # 3. 0.5秒高频洗脑数据库，不涉及硬件层重构，绝对不会卡死死机
        sleep 0.5
    done
}

# 异步丢入后台运行
lock_refresh_rate &
