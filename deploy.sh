#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"

set -euo pipefail

KEEP_BOOT=true
PORT=""
PROJECT_DIR=""
PROJECT_NAME=""
TEMP_DIR=""
STAGING_DIR=""
DUMP_DIR=""
DEVICE_LIST_FILE=""
IGNORE_FILE=""

DEFAULT_EXCLUDES=(
    ".git/"
    ".github/"
    ".gitignore"
    ".uPyDeployignore"
    "__pycache__/"
    ".DS_Store"
    "Thumbs.db"
    "venv/"
    ".venv/"
    "env/"
    "*.pyc"
    "*.pyo"
)

RSYNC_FILTER_ARGS=()

showUsage() {
    cat <<EOF
Usage:
  ./deploy.sh <projectDir> [options]

Options:
  --full-wipe       Remove boot.py Too
  --wipe-all        Same As --full-wipe
  --keep-boot       Keep boot.py (Default)
  --port <device>   Use A Specific Port Instead Of Prompting
  -h, --help        Show This Help

Examples:
  ./deploy.sh ./myProject
  ./deploy.sh ./myProject --full-wipe
  ./deploy.sh ./myProject --port /dev/ttyUSB0
EOF
}

checkDependency() {
    local cmd="$1"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required Command '$cmd' Is Not Installed"
        exit 1
    fi
}

cleanup() {
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

parseArgs() {
    if [ $# -eq 0 ]; then
        showUsage
        exit 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --full-wipe|--wipe-all)
                KEEP_BOOT=false
                shift
                ;;
            --keep-boot)
                KEEP_BOOT=true
                shift
                ;;
            --port)
                if [ $# -lt 2 ]; then
                    echo "ERROR: --port Requires A Value"
                    exit 1
                fi
                PORT="$2"
                shift 2
                ;;
            -h|--help)
                showUsage
                exit 0
                ;;
            -*)
                echo "ERROR: Unknown Option '$1'"
                showUsage
                exit 1
                ;;
            *)
                if [ -n "$PROJECT_DIR" ]; then
                    echo "ERROR: Multiple Project Directories Provided"
                    exit 1
                fi
                PROJECT_DIR="$1"
                shift
                ;;
        esac
    done

    if [ -z "$PROJECT_DIR" ]; then
        echo "ERROR: No Project Directory Provided"
        showUsage
        exit 1
    fi

    if [ ! -d "$PROJECT_DIR" ]; then
        echo "ERROR: Project Directory '$PROJECT_DIR' Does Not Exist"
        exit 1
    fi

    PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
    PROJECT_NAME="$(basename "$PROJECT_DIR")"
    IGNORE_FILE="$PROJECT_DIR/.uPyDeployignore"
}

prepareTempDirs() {
    TEMP_DIR="$(mktemp -d)"
    STAGING_DIR="$TEMP_DIR/staging"
    DUMP_DIR="$TEMP_DIR/deviceDump"
    DEVICE_LIST_FILE="$TEMP_DIR/deviceRootContents.txt"

    mkdir -p "$STAGING_DIR"
    mkdir -p "$DUMP_DIR"
}

choosePort() {
    local ports=()

    if [ -n "$PORT" ]; then
        if [ ! -e "$PORT" ]; then
            echo "ERROR: Port '$PORT' Does Not Exist"
            exit 1
        fi
        return
    fi

    while IFS= read -r port; do
        ports+=("$port")
    done < <(find /dev \( -name 'ttyUSB*' -o -name 'ttyACM*' -o -name 'cu.usb*' \) 2>/dev/null | sort)

    if [ ${#ports[@]} -eq 0 ]; then
        echo "ERROR: No Candidate Serial Devices Found"
        exit 1
    fi

    echo "Available Ports:"
    for i in "${!ports[@]}"; do
        echo "  [$i] ${ports[$i]}"
    done
    echo

    read -rp "Choose Port Number: " portIndex

    if ! [[ "$portIndex" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid Selection"
        exit 1
    fi

    if [ "$portIndex" -lt 0 ] || [ "$portIndex" -ge "${#ports[@]}" ]; then
        echo "ERROR: Selection Out Of Range"
        exit 1
    fi

    PORT="${ports[$portIndex]}"
}

buildRsyncFilterArgs() {
    RSYNC_FILTER_ARGS=()

    local excludePattern
    for excludePattern in "${DEFAULT_EXCLUDES[@]}"; do
        RSYNC_FILTER_ARGS+=(--exclude="$excludePattern")
    done

    if [ -f "$IGNORE_FILE" ]; then
        RSYNC_FILTER_ARGS+=(--exclude-from="$IGNORE_FILE")
    fi
}

showFilterInfo() {
    echo
    echo "Using Default Excludes:"
    local excludePattern
    for excludePattern in "${DEFAULT_EXCLUDES[@]}"; do
        echo "  - $excludePattern"
    done

    echo
    if [ -f "$IGNORE_FILE" ]; then
        echo "Using Project Ignore File: $IGNORE_FILE"
    else
        echo "No Project Ignore File Found"
    fi
}

buildStagingCopy() {
    echo
    echo "Building Staging Copy..."

    rsync -av --delete \
        "${RSYNC_FILTER_ARGS[@]}" \
        "$PROJECT_DIR"/ "$STAGING_DIR"/
}

readDeviceRoot() {
    echo
    echo "Reading Device Root Contents..."
    mpremote connect "$PORT" ls > "$DEVICE_LIST_FILE"

    echo
    echo "===== DEVICE ROOT BEFORE WIPE ====="
    cat "$DEVICE_LIST_FILE"
    echo
}

wipeDeviceRoot() {
    echo "Wiping Device Root Contents..."

    while IFS= read -r line; do
        [ -z "$line" ] && continue

        case "$line" in
            ls\ :*)
                continue
                ;;
        esac

        item="$(echo "$line" | awk '{print $NF}')"
        [ -z "$item" ] && continue

        cleanItem="${item%/}"

        if [ "$KEEP_BOOT" = true ] && [ "$cleanItem" = "boot.py" ]; then
            echo "Keeping: boot.py"
            continue
        fi

        echo "Removing: $cleanItem"
        mpremote connect "$PORT" rm -r ":$cleanItem" 2>/dev/null || \
        mpremote connect "$PORT" rm ":$cleanItem" 2>/dev/null || true

    done < "$DEVICE_LIST_FILE"
}

uploadProject() {
    echo
    echo "Uploading Project Contents To Device Root..."
    mpremote connect "$PORT" cp -r "$STAGING_DIR"/. :
}

pullDeviceForVerification() {
    echo
    echo "Pulling Device Files For Verification..."
    mpremote connect "$PORT" cp -r : "$DUMP_DIR"
}

verifyDeploy() {
    echo
    echo "===== VERIFYING SYNC ====="

    rsync -avnc --delete \
        "${RSYNC_FILTER_ARGS[@]}" \
        "$STAGING_DIR"/ "$DUMP_DIR"/

    echo
    echo "If No Files Are Listed Above, Device Matches Local Deploy Payload"
}

resetDevice() {
    echo
    echo "Resetting Device..."
    mpremote connect "$PORT" reset
}

main() {
    trap cleanup EXIT

    parseArgs "$@"

    checkDependency mpremote
    checkDependency rsync
    checkDependency find
    checkDependency awk
    checkDependency mktemp

    prepareTempDirs
    choosePort
    buildRsyncFilterArgs

    echo
    echo "===== STARTING DEPLOY ====="
    echo "Project Directory: $PROJECT_DIR"
    echo "Project Name: $PROJECT_NAME"
    echo "Using Port: $PORT"

    if [ "$KEEP_BOOT" = true ]; then
        echo "boot.py Handling: Keep Existing boot.py"
    else
        echo "boot.py Handling: Remove boot.py"
    fi

    showFilterInfo
    buildStagingCopy
    readDeviceRoot
    wipeDeviceRoot
    uploadProject
    pullDeviceForVerification
    verifyDeploy
    resetDevice

    echo
    echo "===== DEPLOY COMPLETE ====="
}

main "$@"
