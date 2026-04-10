#!/bin/bash
# smart-browser vendor 依赖下载脚本
# 支持国内镜像，提升下载速度

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$PROJECT_DIR/vendor"

echo "=========================================="
echo "  smart-browser vendor 依赖下载"
echo "=========================================="

# 检测网络
check_network() {
    if curl -s --max-time 5 https://www.google.com >/dev/null 2>&1; then
        NETWORK="global"
        echo -e "${GREEN}✓ 检测到国际网络${NC}"
    elif curl -s --max-time 5 https://www.baidu.com >/dev/null 2>&1; then
        NETWORK="china"
        echo -e "${GREEN}✓ 检测到国内网络，将使用镜像源${NC}"
    else
        NETWORK="unknown"
        echo -e "${YELLOW}⚠ 无法检测网络，将使用官方源${NC}"
    fi
}

# 创建目录
mkdir -p "$VENDOR_DIR/chrome-installers"

# 下载 Chrome
download_chrome() {
    echo ""
    echo "下载 Chrome 安装包..."

    if [ "$NETWORK" = "china" ]; then
        MIRROR_URL="https://mirrors.tuna.tsinghua.edu.cn/chrome/pool/main/g/google-chrome-stable/"
        echo "使用清华大学镜像源..."
    else
        MIRROR_URL="https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/"
    fi

    # 获取最新版本号
    echo "获取最新版本..."
    VERSION=$(curl -s "$MIRROR_URL" | grep -oP 'google-chrome-stable_\K[0-9.]+-1' | head -1 || echo "")

    if [ -z "$VERSION" ]; then
        VERSION="146.0.7680.177-1"
        echo -e "${YELLOW}⚠ 无法获取最新版本，使用默认版本：$VERSION${NC}"
    else
        echo "最新版本：$VERSION"
    fi

    FILENAME="google-chrome-stable_${VERSION}_amd64.deb"
    TARGET="$VENDOR_DIR/chrome-installers/$FILENAME"

    if [ -f "$TARGET" ]; then
        echo -e "${GREEN}✓ Chrome 安装包已存在${NC}"
        return
    fi

    # 下载
    if [ "$NETWORK" = "china" ]; then
        wget -q --show-progress \
            "$MIRROR_URL$FILENAME" \
            -O "$TARGET" || {
            echo -e "${YELLOW}⚠ 清华镜像下载失败，尝试官方源...${NC}"
            wget -q --show-progress \
                "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/$FILENAME" \
                -O "$TARGET"
        }
    else
        wget -q --show-progress \
            "$MIRROR_URL$FILENAME" \
            -O "$TARGET"
    fi

    if [ -f "$TARGET" ] && [ -s "$TARGET" ]; then
        echo -e "${GREEN}✓ Chrome 安装包下载完成${NC}"
        ls -lh "$TARGET"
    else
        echo -e "${RED}✗ Chrome 下载失败${NC}"
        exit 1
    fi
}

# 下载 noVNC
download_novnc() {
    echo ""
    echo "下载 noVNC..."

    if [ -d "$VENDOR_DIR/noVNC" ] && [ -f "$VENDOR_DIR/noVNC/vnc.html" ]; then
        echo -e "${GREEN}✓ noVNC 已存在${NC}"
        return
    fi

    # 清理不完整的克隆
    rm -rf "$VENDOR_DIR/noVNC"

    if [ "$NETWORK" = "china" ]; then
        echo "使用 Gitee 镜像..."
        git clone --depth 1 https://gitee.com/mirrors/noVNC.git "$VENDOR_DIR/noVNC" || {
            echo -e "${YELLOW}⚠ Gitee 克隆失败，尝试 GitHub...${NC}"
            git clone --depth 1 https://github.com/novnc/noVNC.git "$VENDOR_DIR/noVNC"
        }
    else
        git clone --depth 1 https://github.com/novnc/noVNC.git "$VENDOR_DIR/noVNC"
    fi

    if [ -d "$VENDOR_DIR/noVNC" ]; then
        echo -e "${GREEN}✓ noVNC 下载完成${NC}"
        ls -lh "$VENDOR_DIR/noVNC" | head -5
    else
        echo -e "${RED}✗ noVNC 下载失败${NC}"
        exit 1
    fi
}

# 主流程
check_network
download_chrome
download_novnc

echo ""
echo "=========================================="
echo "  下载完成！"
echo "=========================================="
echo ""
echo "vendor/ 目录内容："
du -sh "$VENDOR_DIR"/*

echo ""
echo "下一步：运行 ./scripts/install.sh 安装"
