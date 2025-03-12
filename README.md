# 股票监控系统

一个基于 FastAPI 和 React 的实时股票监控系统，可以监控 A 股股票的价格和交易量变化，并提供实时预警功能。

## 功能特点

- 支持同时监控最多 10 个 A 股股票
- 实时监控股票价格变动（涨跌幅超过 3%）
- 实时监控交易量变化（放大到 2 倍）
- WebSocket 实时推送预警信息
- 美观的 Ant Design 界面
- Docker 容器化部署

## 技术栈

### 后端
- Python 3.10
- FastAPI
- WebSocket
- Baostock（股票数据源）

### 前端
- React 18
- TypeScript
- Ant Design
- WebSocket

### 部署
- Docker
- Nginx
- Docker Compose

## 快速开始

1. 克隆仓库
```bash
git clone [仓库地址]
cd stock-monitor
```

2. 使用 Docker Compose 启动服务
```bash
docker-compose up -d --build
```

3. 访问应用
打开浏览器访问 `http://localhost:8888`

## 项目结构

```
stock-monitor/
├── backend/                # 后端项目目录
│   ├── main.py            # 主应用文件
│   ├── requirements.txt   # Python 依赖
│   └── Dockerfile         # 后端 Docker 配置
├── frontend/              # 前端项目目录
│   ├── src/              # 源代码
│   ├── public/           # 静态资源
│   ├── package.json      # 项目配置
│   └── Dockerfile        # 前端 Docker 配置
├── docker-compose.yml    # Docker 编排配置
└── README.md             # 项目说明
```

## 开发说明

### 后端开发
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: .\venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 前端开发
```bash
cd frontend
npm install
npm start
```

## 部署

详细的部署说明请参考 [deployment_guide.txt](deployment_guide.txt)。

## 待优化功能

1. 数据持久化
   - 添加数据库支持
   - 保存历史预警记录

2. 用户系统
   - 添加用户认证
   - 个性化配置

3. 更多监控指标
   - 支持更多技术指标
   - 自定义预警阈值

4. 通知系统
   - 邮件通知
   - 短信通知

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交改动 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件 