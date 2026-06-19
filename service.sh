#!/system/bin/sh
# 极其保守的开机等待，安全第一（延长到 40 秒，确保所有核心服务死透了再启动）
sleep 40

lock_refresh_rate() {
    # 安全锁：确保系统完全起来后，只在后台低调执行合法的 Settings 写入
    while true; do
        # 1. 锁死全局与最高/最低刷新率
        settings put system peak_refresh_rate 120.0 >/dev/null 2>&1
        settings put system min_refresh_rate 120.0 >/dev/null 2>&1
        settings put secure user_refresh_rate 120 >/dev/null 2>&1
        
        # 2. 核心安全锁：强行关闭“根据内容和温控动态匹配帧率”机制 (0 代表永远不匹配降频)
        # 这一行能极大程度缓解温控导致的 120 和 60 来回乱跳
        settings put system match_content_frame_rate 0 >/dev/null 2>&1

        # 3. 拦截物理降频 (不调分辨率，只调 Mode ID，安全且不伤显示通道)
        CURRENT_MODE=$(dumpsys display | grep -E "mActiveDisplayModeId|mActiveModeId" | head -n 1 | grep -oE "[0-9]+")
        if [ "$CURRENT_MODE" = "1" ]; then
            # 只有当发现物理 Mode 真的跌回 1 时，才使用 cmd display 顶回去
            cmd display set-display-mode-id 2 >/dev/null 2>&1
        fi

        # 保持 3 秒一次的监控步长，既兼顾了响应速度，又避免了短时间密集调用卡死 CPU
        sleep 3
    done
}

# 异步丢入后台运行
lock_refresh_rate &
