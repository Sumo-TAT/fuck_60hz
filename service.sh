#!/system/bin/sh
# 等待系统开机完全加载
sleep 30

lock_refresh_rate() {
    while true; do
        settings put system peak_refresh_rate 120.0
        settings put system min_refresh_rate 120.0
        settings put secure user_refresh_rate 120
        sleep 5
    done
}

# 异步丢入后台，绝对不卡开机
lock_refresh_rate &
