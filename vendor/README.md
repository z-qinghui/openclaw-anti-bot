# Vendor 依赖目录

本目录包含 smart-browser 项目所需的离线依赖包，用于提升安装速度，避免网络下载失败。

## 目录结构

```
vendor/
├── chrome-installers/
│   └── google-chrome-stable.deb    # Chrome 离线安装包 (约 120MB)
├── noVNC/                           # noVNC 源码
│   ├── vnc.html
│   ├── core/
│   └── ...
└── README.md                        # 本文件
```

## 下载依赖

### 方式一：使用下载脚本（推荐）

```bash
cd /root/workspace/smart-browser
./scripts/download-vendor.sh
```

### 方式二：手动下载

#### 1. Chrome 安装包

```bash
mkdir -p vendor/chrome-installers
wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_146.0.7680.177-1_amd64.deb \
  -O vendor/chrome-installers/google-chrome-stable.deb
```

#### 2. noVNC

```bash
mkdir -p vendor
git clone --depth 1 https://github.com/novnc/noVNC.git vendor/noVNC
```

## 更新依赖

当需要更新 Chrome 版本时：

```bash
# 获取最新版本号
wget -q https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/ \
  -O - | grep -oP 'google-chrome-stable_\K[0-9.]+-1' | head -1

# 下载新版本
wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_<VERSION>.deb \
  -O vendor/chrome-installers/google-chrome-stable.deb
```

## Git 配置

`.gitignore` 已配置忽略大型二进制文件：

```
vendor/**/*.deb
vendor/**/*.tar.gz
```

如需将依赖提交到 Git（例如私有仓库）：

```bash
git add vendor/
git commit -m "vendor: add offline dependencies"
```

## 文件大小

- Chrome: ~120MB
- noVNC: ~5MB

## 故障排查

### 下载速度慢

使用国内镜像：

```bash
# Chrome (清华大学镜像站)
wget https://mirrors.tuna.tsinghua.edu.cn/chrome/pool/main/g/google-chrome-stable/google-chrome-stable_146.0.7680.177-1_amd64.deb \
  -O vendor/chrome-installers/google-chrome-stable.deb
```

### noVNC 克隆失败

使用 Gitee 镜像：

```bash
git clone --depth 1 https://gitee.com/mirrors/noVNC.git vendor/noVNC
```
