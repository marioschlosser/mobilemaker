#!/bin/bash
# Test Harness CLI - convenience wrapper for interacting with the in-game test harness.
#
# Usage:
#   ./scripts/harness.sh ping
#   ./scripts/harness.sh state
#   ./scripts/harness.sh actions
#   ./scripts/harness.sh tap <x> <y>
#   ./scripts/harness.sh action <name> [json_params]
#   ./scripts/harness.sh screenshot <output_path>
#   ./scripts/harness.sh port

set -euo pipefail

PORT="${HARNESS_PORT:-7483}"
BASE="http://localhost:${PORT}"

usage() {
    echo "Usage: $0 <command> [args...]"
    echo ""
    echo "Commands:"
    echo "  ping                      Check if harness is running"
    echo "  state                     Get current game state"
    echo "  actions                   List available game actions"
    echo "  tap <x> <y>              Tap at coordinates"
    echo "  action <name> [params]    Execute named action (params as JSON object)"
    echo "  screenshot <path>         Take simulator screenshot"
    echo "  port                      Discover harness port from running app"
    echo ""
    echo "Environment:"
    echo "  HARNESS_PORT   Override port (default: 7483)"
    exit 1
}

cmd_ping() {
    curl -s "${BASE}/ping" | python3 -m json.tool 2>/dev/null || curl -s "${BASE}/ping"
}

cmd_state() {
    curl -s "${BASE}/state" | python3 -m json.tool 2>/dev/null || curl -s "${BASE}/state"
}

cmd_actions() {
    curl -s "${BASE}/actions" | python3 -m json.tool 2>/dev/null || curl -s "${BASE}/actions"
}

cmd_tap() {
    local x="${1:?Missing x coordinate}"
    local y="${2:?Missing y coordinate}"
    curl -s -X POST "${BASE}/tap" \
        -H "Content-Type: application/json" \
        -d "{\"x\":${x},\"y\":${y}}" | python3 -m json.tool 2>/dev/null || \
    curl -s -X POST "${BASE}/tap" \
        -H "Content-Type: application/json" \
        -d "{\"x\":${x},\"y\":${y}}"
}

cmd_action() {
    local name="${1:?Missing action name}"
    local params="${2:-{}}"
    curl -s -X POST "${BASE}/action" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${name}\",\"parameters\":${params}}" | python3 -m json.tool 2>/dev/null || \
    curl -s -X POST "${BASE}/action" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${name}\",\"parameters\":${params}}"
}

cmd_screenshot() {
    local path="${1:?Missing output path}"
    xcrun simctl io booted screenshot "${path}" 2>/dev/null
    echo "Screenshot saved to ${path}"
}

cmd_port() {
    # Try to read port from the app's Documents directory in the simulator
    local container
    container=$(xcrun simctl get_app_container booted com.landscapetapper.app data 2>/dev/null || true)
    if [[ -n "${container}" ]]; then
        local port_file="${container}/Documents/testharness_port.txt"
        if [[ -f "${port_file}" ]]; then
            cat "${port_file}"
            return 0
        fi
    fi
    echo "Could not discover port. Is the app running in the simulator?"
    return 1
}

# Main dispatch
case "${1:-}" in
    ping)       cmd_ping ;;
    state)      cmd_state ;;
    actions)    cmd_actions ;;
    tap)        shift; cmd_tap "$@" ;;
    action)     shift; cmd_action "$@" ;;
    screenshot) shift; cmd_screenshot "$@" ;;
    port)       cmd_port ;;
    *)          usage ;;
esac
