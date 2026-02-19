#!/bin/sh
# WireGuard Tunnel Health Check Script
# Exit codes: 0 = All checks passed, 1 = One or more checks failed

EXIT_CODE=0

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

# 2. Check gateway 10.0.253.1 reachability
if ping -c 1 -W 2 10.0.253.1 >/dev/null 2>&1; then
    log_ok "Gateway 10.0.253.1 is reachable"
else
    log_fail "Gateway 10.0.253.1 is unreachable"
fi

# 3. Check route to 172.16.0.0/16
if ip route show | grep -q "172.16.0.0/16"; then
    log_ok "Route to 172.16.0.0/16 exists"
else
    log_fail "Route to 172.16.0.0/16 is missing"
fi

# 4. Check DNS resolution for jira.micran.ru via 172.16.0.1
if timeout 5 nslookup jira.micran.ru 172.16.0.1 >/dev/null 2>&1; then
    log_ok "DNS resolution for jira.micran.ru via 172.16.0.1 successful"
else
    log_fail "DNS resolution for jira.micran.ru via 172.16.0.1 failed"
fi

# 5. Check route to 172.17.0.0/16 and ping report.micran.ru
ROUTE_172_17=0
if ip route show | grep -q "172.17.0.0/16"; then
    ROUTE_172_17=1
fi

PING_REPORT=0
if ping -c 1 -W 2 report.micran.ru >/dev/null 2>&1; then
    PING_REPORT=1
fi

if [ "$ROUTE_172_17" -eq 1 ] && [ "$PING_REPORT" -eq 1 ]; then
    log_ok "Route 172.17.0.0/16 exists and report.micran.ru is pingable"
else
    log_fail "Route 172.17.0.0/16 or report.micran.ru ping check failed"
fi

# 6. Check route to 192.168.26.0/24 and ping 192.168.26.1
ROUTE_192_168_26=0
if ip route show | grep -q "192.168.26.0/24"; then
    ROUTE_192_168_26=1
fi

PING_192_168_26_1=0
if ping -c 1 -W 2 192.168.26.1 >/dev/null 2>&1; then
    PING_192_168_26_1=1
fi

if [ "$ROUTE_192_168_26" -eq 1 ] && [ "$PING_192_168_26_1" -eq 1 ]; then
    log_ok "Route 192.168.26.0/24 exists and 192.168.26.1 is pingable"
else
    log_fail "Route 192.168.26.0/24 or 192.168.26.1 ping check failed"
fi

# Final Exit
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "All checks passed."
else
    echo "Some checks failed."
fi

exit "$EXIT_CODE"