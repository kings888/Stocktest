# 部署配置说明

## 快速开始

1. 复制配置模板：
```bash
cp deploy.config.template deploy.config
```

2. 编辑 deploy.config 文件，填写必要信息：
- GITHUB_REPO: GitHub仓库名（格式：用户名/仓库名）
- SERVER_HOST: 服务器IP地址
- SERVER_USERNAME: 服务器用户名
- DEPLOY_PATH: 部署路径（可选，默认为 /home/{USERNAME}/StockTest）
- BRANCH: 部署分支（可选，默认为 main）

3. 运行配置脚本：
```bash
chmod +x setup_deploy.sh
./setup_deploy.sh
```

4. 按照脚本输出的步骤完成配置：
- 在服务器上生成 SSH 密钥
- 配置 authorized_keys
- 在 GitHub 中添加 Secrets

## 配置文件说明

### deploy.config
包含部署所需的基本配置信息，可以根据需要修改。修改后重新运行 setup_deploy.sh 更新配置。

### .github/workflows/deploy.yml
GitHub Actions 的工作流配置文件，由 setup_deploy.sh 自动生成，通常不需要手动修改。

## 注意事项

1. 确保服务器已安装 Docker 和 Docker Compose
2. 确保服务器用户具有 Docker 权限
3. 确保 GitHub 仓库已正确配置 Secrets
4. 部署路径需要具有适当的权限

## 故障排查

1. 如果部署失败，检查：
   - GitHub Actions 日志
   - 服务器上的 Docker 日志
   - SSH 密钥配置是否正确

2. 常见问题：
   - 权限问题：确保用户在 docker 组中
   - 网络问题：检查防火墙设置
   - 存储问题：确保服务器有足够的磁盘空间 