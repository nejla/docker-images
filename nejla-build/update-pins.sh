#!/usr/bin/env bash
set -euo pipefail

# Updates pinned versions and SHA256 hashes in the Dockerfile.
# Dependencies: curl, jq, sha256sum
#
# Usage:
#   ./update-pins.sh [--dry-run] [--dockerfile PATH]
#
# --dry-run: prints what would change without modifying the file.
#            Exits 0 if everything is current, 1 if updates are available.

DOCKERFILE="Dockerfile"
DRY_RUN=false
CHANGES_FOUND=false
RUST_ARCH="x86_64-unknown-linux-gnu"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)    DRY_RUN=true; shift ;;
        --dockerfile) DOCKERFILE="$2"; shift 2 ;;
        *)            echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

[[ -f "$DOCKERFILE" ]] || { echo "Dockerfile not found: $DOCKERFILE" >&2; exit 1; }

for cmd in curl jq sha256sum; do
    command -v "$cmd" &>/dev/null || { echo "Missing dependency: $cmd" >&2; exit 1; }
done

# --- Helpers ---

current_arg() {
    grep -oP "^ARG $1=\K.*" "$DOCKERFILE" | tr -d "\"'"
}

update_arg() {
    local name="$1" value="$2"
    $DRY_RUN && return
    sed -i "s|^ARG ${name}=.*|ARG ${name}=${value}|" "$DOCKERFILE"
}

fetch_sha256() {
    local url="$1" tmp
    tmp=$(mktemp)
    trap "rm -f '$tmp'" RETURN
    echo "  Downloading $(basename "$url")..." >&2
    curl -fsSL "$url" -o "$tmp"
    sha256sum "$tmp" | cut -d' ' -f1
}

report() {
    local name="$1" old="$2" new="$3"
    if [[ "$old" == "$new" ]]; then
        echo "  $name: $old (unchanged)"
    else
        echo "  $name: $old -> $new"
        CHANGES_FOUND=true
    fi
}

# --- Base image (ubuntu) ---

echo "Checking base image..."

# Parse FROM line: ubuntu:24.04 or ubuntu:24.04@sha256:...
FROM_LINE=$(grep -m1 '^FROM ' "$DOCKERFILE")
BASE_TAG=$(echo "$FROM_LINE" | sed -E 's/^FROM ([^@ ]+).*/\1/')  # ubuntu:24.04
CURRENT_DIGEST=$(echo "$FROM_LINE" | grep -oP '@\Ksha256:[a-f0-9]+' || echo "none")
TAG_VERSION=$(echo "$BASE_TAG" | cut -d: -f2)  # 24.04
CURRENT_LTS_YEAR=$(echo "$TAG_VERSION" | cut -d. -f1)  # 24

# Get a Docker Hub auth token (anonymous pull scope)
DOCKER_TOKEN=$(curl -fsSL \
    "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/ubuntu:pull" \
    | jq -r .token)

# Fetch the current digest for the tag
LATEST_DIGEST=$(curl -fsSI \
    -H "Authorization: Bearer $DOCKER_TOKEN" \
    -H "Accept: application/vnd.docker.distribution.manifest.list.v2+json" \
    -H "Accept: application/vnd.oci.image.index.v1+json" \
    "https://registry-1.docker.io/v2/library/ubuntu/manifests/${TAG_VERSION}" \
    | grep -i '^docker-content-digest:' | tr -d '\r' | awk '{print $2}')

[[ -n "$LATEST_DIGEST" ]] || { echo "  Failed to fetch digest for ${BASE_TAG}" >&2; exit 1; }

report "digest" "$CURRENT_DIGEST" "$LATEST_DIGEST"

if ! $DRY_RUN; then
    NEW_FROM="FROM ${BASE_TAG}@${LATEST_DIGEST}"
    sed -i "s|^FROM .*|${NEW_FROM}|" "$DOCKERFILE"
fi

# Check for newer Ubuntu LTS releases (YY.04 where YY is even)
echo "  Checking for newer Ubuntu LTS releases..."
NEWER_LTS=$(curl -fsSL "https://hub.docker.com/v2/repositories/library/ubuntu/tags?page_size=100" \
    | jq -r '.results[].name' \
    | grep -E '^[0-9]{2}\.04$' \
    | sort -V \
    | awk -F. -v cur="$CURRENT_LTS_YEAR" '$1 > cur && $1 % 2 == 0' \
    || true)

if [[ -n "$NEWER_LTS" ]]; then
    echo "  WARNING: Newer Ubuntu LTS available: ${NEWER_LTS} (current: ${TAG_VERSION})"
else
    echo "  No newer Ubuntu LTS found."
fi

# --- Stack ---

echo "Checking Stack..."
OLD_STACK_VERSION=$(current_arg STACK_VERSION)
OLD_STACK_SHA256=$(current_arg STACK_SHA256)

STACK_VERSION=$(curl -fsSL https://api.github.com/repos/commercialhaskell/stack/releases/latest \
    | jq -r '.tag_name' | sed 's/^v//')

STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz"
STACK_SHA256=$(fetch_sha256 "$STACK_URL")

report "version" "$OLD_STACK_VERSION" "$STACK_VERSION"
report "sha256 " "$OLD_STACK_SHA256" "$STACK_SHA256"

update_arg STACK_VERSION "$STACK_VERSION"
update_arg STACK_SHA256  "\"$STACK_SHA256\""

# --- Rustup ---

echo "Checking Rustup..."
OLD_RUSTUP_VER=$(current_arg RUSTUP_VER)
OLD_RUSTUP_SHA256=$(current_arg RUSTUP_SHA256)

RUSTUP_STABLE=$(curl -fsSL https://static.rust-lang.org/rustup/release-stable.toml)
RUSTUP_VER=$(echo "$RUSTUP_STABLE" | grep -oP "^version\s*=\s*'\K[^']+")

RUSTUP_URL="https://static.rust-lang.org/rustup/archive/${RUSTUP_VER}/${RUST_ARCH}/rustup-init"
RUSTUP_SHA256=$(fetch_sha256 "$RUSTUP_URL")

report "version" "$OLD_RUSTUP_VER" "$RUSTUP_VER"
report "sha256 " "$OLD_RUSTUP_SHA256" "$RUSTUP_SHA256"

update_arg RUSTUP_VER    "\"$RUSTUP_VER\""
update_arg RUSTUP_SHA256 "'$RUSTUP_SHA256'"

# --- Exit ---

echo ""
if $DRY_RUN; then
    if $CHANGES_FOUND; then
        echo "Updates available. Run without --dry-run to apply."
        exit 1
    else
        echo "Everything is up to date."
        exit 0
    fi
else
    if $CHANGES_FOUND; then
        echo "Updated: $DOCKERFILE"
    else
        echo "No changes needed: $DOCKERFILE"
    fi
fi
