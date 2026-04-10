#!/bin/bash
# smart-browser 一键安装脚本
# 优先使用 vendor 目录的本地依赖，提升安装速度

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$PROJECT_DIR/vendor"

echo "=========================================="
echo "  smart-browser 一键安装"
echo "=========================================="

# 检测环境
if [ -d "/home/node/.openclaw" ]; then
    MODE="container"
    echo -e "${YELLOW}检测到 OpenClaw 容器环境${NC}"
    echo "VNC 服务应在宿主机运行，容器内仅需 CDP Proxy"
elif command -v docker &>/dev/null; then
    MODE="docker"
    echo -e "${GREEN}检测到 Docker 环境${NC}"
else
    MODE="standalone"
    echo -e "${GREEN}检测到宿主机环境，使用独立模式${NC}"
fi

# 检查 vendor 目录
check_vendor() {
    if [ -f "$VENDOR_DIR/chrome-installers/google-chrome-stable.deb" ]; then
        echo -e "${GREEN}✓ 检测到本地 Chrome 安装包${NC}"
        USE_LOCAL_CHROME=true
    else
        echo -e "${YELLOW}⚠ 未检测到本地 Chrome 安装包，将从网络下载${NC}"
        USE_LOCAL_CHROME=false
    fi

    if [ -d "$VENDOR_DIR/noVNC" ]; then
        echo -e "${GREEN}✓ 检测到本地 noVNC${NC}"
        USE_LOCAL_NOVNC=true
    else
        echo -e "${YELLOW}⚠ 未检测到本地 noVNC，将从网络下载${NC}"
        USE_LOCAL_NOVNC=false
    fi
}

case "$MODE" in
  standalone)
    check_vendor

    echo ""
    echo "正在安装系统依赖..."

    if command -v apt-get &>/dev/null; then
        apt-get update

        # 安装 Chrome
        if [ "$USE_LOCAL_CHROME" = true ]; then
            echo "正在安装本地 Chrome..."
            dpkg -i "$VENDOR_DIR/chrome-installers/google-chrome-stable.deb" || apt-get install -f -y
        else
            echo "正在从网络下载 Chrome..."
            wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_146.0.7680.177-1_amd64.deb -O /tmp/chrome.deb
            dpkg -i /tmp/chrome.deb || apt-get install -f -y
            rm /tmp/chrome.deb
        fi

        # 安装系统依赖
        apt-get install -y \
            tigervnc-standalone-server \
            websockify \
            nginx \
            fonts-noto \
            fonts-noto-cjk \
            fonts-wqy-zenhei \
            fonts-wqy-microhei \
            nodejs \
            npm \
            jq \
            xfce4 \
            xfce4-goodies \
            fcitx5 \
            fcitx5-pinyin \
            socat || {
            echo -e "${YELLOW}部分依赖安装失败，继续执行...${NC}"
        }

        # 安装 noVNC
        if [ "$USE_LOCAL_NOVNC" = false ]; then
            echo "正在安装 noVNC..."
            apt-get install -y novnc || {
                echo -e "${YELLOW}noVNC 安装失败，使用备用方案...${NC}"
            }
        fi
    else
        echo -e "${YELLOW}未知的包管理器，请手动安装依赖${NC}"
        exit 1
    fi

    echo ""
    echo "正在启动 VNC 服务..."
    bash vnc/rc.chrome-vnc.sh

    echo ""
    echo "正在启动 CDP Proxy..."
    CDP_CHROME_HOST=127.0.0.1 CDP_CHROME_PORT=9222 \
        node scripts/cdp-proxy.mjs &

    echo ""
    echo "=========================================="
    echo "  安装完成！"
    echo "=========================================="
    echo ""
    echo "VNC 访问：http://localhost:6080/vnc.html"
    echo "默认密码：admin2026"
    echo "CDP Proxy: http://localhost:3456"
    ;;

  docker)
    echo ""
    echo "使用 Docker Compose 启动服务..."

    # 检查 vendor 目录
    if [ ! -d "$VENDOR_DIR/noVNC" ] || [ ! -f "$VENDOR_DIR/chrome-installers/google-chrome-stable.deb" ]; then
        echo -e "${YELLOW}⚠ vendor 目录不完整，请先运行：git submodule update --init --recursive${NC}"
        echo "或从网络拉取依赖..."
    fi

    echo "运行：docker-compose up -d"
    ;;

  container)
    echo ""
    echo "OpenClaw 环境中，请确保宿主机 VNC 服务已运行"
    echo "CDP Proxy 将自动连接宿主机 Chrome:9222"
    ;;
esac

echo ""
echo "运行 ./scripts/check-deps.sh 验证安装"
