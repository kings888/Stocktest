#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否存在配置文件
if [ ! -f "deploy.config" ]; then
    echo -e "${YELLOW}未找到配置文件，将从模板创建...${NC}"
    cp deploy.config.template deploy.config
fi

# 读取配置文件
source deploy.config

# 检查并提示填写必要信息
if [ -z "$GITHUB_REPO" ]; then
    read -p "请输入GitHub仓库名（格式：用户名/仓库名）: " GITHUB_REPO
    sed -i "s/GITHUB_REPO=.*/GITHUB_REPO=$GITHUB_REPO/" deploy.config
fi

if [ -z "$SERVER_HOST" ]; then
    read -p "请输入服务器IP: " SERVER_HOST
    sed -i "s/SERVER_HOST=.*/SERVER_HOST=$SERVER_HOST/" deploy.config
fi

if [ -z "$SERVER_USERNAME" ]; then
    read -p "请输入服务器用户名: " SERVER_USERNAME
    sed -i "s/SERVER_USERNAME=.*/SERVER_USERNAME=$SERVER_USERNAME/" deploy.config
fi

if [ -z "$DEPLOY_PATH" ]; then
    DEPLOY_PATH="/home/$SERVER_USERNAME/StockTest"
    sed -i "s#DEPLOY_PATH=.*#DEPLOY_PATH=$DEPLOY_PATH#" deploy.config
fi

# 确保.github/workflows目录存在
mkdir -p .github/workflows

# 生成GitHub Actions配置文件
cat > .github/workflows/deploy.yml << EOL
name: Deploy to Ubuntu Server

on:
  push:
    branches: [ $BRANCH ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Deploy to Server
        uses: appleboy/ssh-action@master
        with:
          host: \${{ secrets.SERVER_HOST }}
          username: \${{ secrets.SERVER_USERNAME }}
          key: \${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd $DEPLOY_PATH
            if [ ! -d ".git" ]; then
              git clone \${{ github.server_url }}/\${{ github.repository }} .
            else
              git fetch --all
              git reset --hard origin/$BRANCH
            fi
            docker-compose down
            docker system prune -f --volumes
            docker-compose up -d --build
EOL

echo -e "${GREEN}配置文件已生成！${NC}"
echo -e "${YELLOW}请按照以下步骤完成配置：${NC}"
echo -e "1. 在服务器上生成SSH密钥："
echo -e "   ${GREEN}ssh-keygen -t ed25519 -C \"github-actions-deploy\"${NC}"
echo
echo -e "2. 查看并复制公钥内容："
echo -e "   ${GREEN}cat ~/.ssh/id_ed25519.pub${NC}"
echo -e "   将公钥添加到服务器的authorized_keys："
echo -e "   ${GREEN}cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys${NC}"
echo
echo -e "3. 查看并复制私钥内容："
echo -e "   ${GREEN}cat ~/.ssh/id_ed25519${NC}"
echo
echo -e "4. 在GitHub仓库设置中添加以下Secrets："
echo -e "   SERVER_HOST: $SERVER_HOST"
echo -e "   SERVER_USERNAME: $SERVER_USERNAME"
echo -e "   SERVER_SSH_KEY: (第3步复制的私钥内容)"
echo
echo -e "5. 在服务器上创建部署目录："
echo -e "   ${GREEN}mkdir -p $DEPLOY_PATH${NC}"
echo
echo -e "${YELLOW}配置完成后，每次推送到 $BRANCH 分支都会自动部署到服务器。${NC}" 