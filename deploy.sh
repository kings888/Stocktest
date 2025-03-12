#!/bin/bash

# 配置信息
SERVER_HOST="your-server-ip"
SERVER_USER="your-username"
SERVER_PATH="/path/to/your/project"
BRANCH="main"  # 或你的主分支名称

# 确保本地更改已提交
if [ -n "$(git status --porcelain)" ]; then
    echo "有未提交的更改，请先提交或存储更改"
    exit 1
fi

# 推送到远程仓库
echo "推送代码到远程仓库..."
git push origin $BRANCH

# 连接到服务器并部署
echo "开始部署到服务器..."
ssh $SERVER_USER@$SERVER_HOST << 'ENDSSH'
    cd $SERVER_PATH
    git pull
    docker-compose down
    docker system prune -f
    docker-compose up -d --build
    echo "部署完成！"
ENDSSH 