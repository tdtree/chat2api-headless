# Chat2API Headless 部署

## 新服务器部署

```bash
# 1. 安装依赖
yum install -y git nodejs npm xorg-x11-server-Xvfb
# 或 apt install -y git nodejs npm xvfb

# 2. 克隆
git clone git@github.com:tdtree/chat2api-headless.git Chat2API
cd Chat2API

# 3. 安装 & 构建
npm install
npm run build

# 4. 复制 WASM
cp sha3_wasm_bg.7b9ca65ddd.wasm out/main/

# 5. 启动 (run-headless.sh 已自动复制 WASM)
bash run-headless.sh start

# 6. 验证
curl http://localhost:6011/health
```

## Nginx 配置

参考 `deploy/nginx.conf`，把域名和 SSL 路径改为新服务器的。

## 管理页面

`deploy/admin.html` 放到 nginx 静态目录。

## 管理 API

启动后通过 admin 页面或 API 配置提供商、添加账号、设置模型映射。
