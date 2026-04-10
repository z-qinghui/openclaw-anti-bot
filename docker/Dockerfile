FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV RESOLUTION=1920x1080

# 安装系统依赖（不包含 Chrome）
RUN apt-get update && apt-get install -y \
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
    curl \
    socat \
    wget \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    libu2f-udev \
    libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

# 安装本地 Chrome（从 vendor 目录）
COPY vendor/chrome-installers/google-chrome-stable.deb /tmp/chrome.deb
RUN dpkg -i /tmp/chrome.deb || apt-get install -f -y && rm /tmp/chrome.deb

# 创建目录
RUN mkdir -p /var/chrome-data /opt/vnc-auth /opt/cdp-proxy

# 复制应用文件
COPY vnc/rc.chrome-vnc.sh /etc/rc.chrome-vnc.sh
COPY vnc/auth-server.js /opt/vnc-auth/auth-server.js
COPY vnc/login.html /opt/vnc-auth/login.html
COPY scripts/cdp-proxy.mjs /opt/cdp-proxy.mjs
COPY docker/nginx/nginx.conf /etc/nginx/sites-available/default

# 复制 noVNC（从 vendor 目录）
COPY vendor/noVNC /usr/share/noVNC

RUN chmod +x /etc/rc.chrome-vnc.sh

# 暴露端口
EXPOSE 6080 8080 9222 3456

# 启动脚本
CMD ["/etc/rc.chrome-vnc.sh"]
