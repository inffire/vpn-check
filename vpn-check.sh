#!/bin/sh
# WireGuard Tunnel Health Check Script
# Exit codes: 0 = All checks passed, 1 = One or more checks failed

EXIT_CODE=0
TOMSK_GW="10.0.253.1"

log_ok() {
    echo "[OK] $1"
}

log_fail() {
    echo "[FAIL] $1"
    EXIT_CODE=1
}

# 1. Check local IP assignment from 10.0.253.0/24 subnet
if ip addr show | grep -q "inet 10.0.253."; then
    log_ok "Local IP from 10.0.253.0/24 subnet is assigned"
else
    log_fail "No local IP from 10.0.253.0/24 subnet found"
fi

# 2. Check gateway reachability
if ping -c 1 -W 2 "$TOMSK_GW" >/dev/null 2>&1; then
    log_ok "Gateway $TOMSK_GW is reachable"
else
    log_fail "Gateway $TOMSK_GW is unreachable"
fi

# 3. Check route to 172.16.0.1/32 (dsvch) via gateway
if ip route get 172.16.0.1 2>/dev/null | grep -q "via $TOMSK_GW"; then
    log_ok "Route to 172.16.0.1/32 (dsvch) via $TOMSK_GW exists"
else
    log_fail "Route to 172.16.0.1/32 (dsvch) via $TOMSK_GW is missing"
fi

# 3a. Check route to 172.17.0.1/32 (kirova) via gateway
if ip route get 172.17.0.1 2>/dev/null | grep -q "via $TOMSK_GW"; then
    log_ok "Route to 172.17.0.1/32 (kirova) via $TOMSK_GW exists"
else
    log_fail "Route to 172.17.0.1/32 (kirova) via $TOMSK_GW is missing"
fi

# 3b. Check route to 172.18.200.17/32 (srv20-service) via gateway
if ip route get 172.18.200.17 2>/dev/null | grep -q "via $TOMSK_GW"; then
    log_ok "Route to 172.18.200.17/32 (srv20-service) via $TOMSK_GW exists"
else
    log_fail "Route to 172.18.200.17/32 (srv20-service) via $TOMSK_GW is missing"
fi

# 4. Check DNS resolution for jira.micran.ru via 172.16.0.1
if timeout 5 nslookup jira.micran.ru 172.16.0.1 >/dev/null 2>&1; then
    log_ok "DNS resolution for jira.micran.ru via 172.16.0.1 successful"
else
    log_fail "DNS resolution for jira.micran.ru via 172.16.0.1 failed"
fi

# 5. Check ping to jira.micran.ru
if ping -c 1 -W 2 jira.micran.ru >/dev/null 2>&1; then
    log_ok "jira.micran.ru is pingable"
else
    log_fail "jira.micran.ru is not pingable"
fi

# 6. Check ping to report.micran.ru
if ping -c 1 -W 2 report.micran.ru >/dev/null 2>&1; then
    log_ok "report.micran.ru is pingable"
else
    log_fail "report.micran.ru is not pingable"
fi

# 7. Check route to 192.168.26.0/24 and ping 192.168.26.1
if ip route get 192.168.26.1 2>/dev/null | grep -q "via $TOMSK_GW"; then
    log_ok "Route to 192.168.26.0/24 via $TOMSK_GW exists"
else
    log_fail "Route to 192.168.26.0/24 via $TOMSK_GW is missing"
fi

if ping -c 1 -W 2 192.168.26.1 >/dev/null 2>&1; then
    log_ok "192.168.26.1 is pingable"
else
    log_fail "192.168.26.1 is not pingable"
fi

exit "$EXIT_CODE"