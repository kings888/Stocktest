FROM node:18-alpine as build

WORKDIR /app

# 创建新的React项目
RUN npx create-react-app . --template typescript

# 复制我们的源代码和配置文件
COPY package*.json ./
COPY src/ src/
COPY public/ public/

# 安装依赖并构建
RUN npm install
RUN npm install antd @ant-design/icons
RUN npm run build

# 生产环境
FROM nginx:alpine

# 复制构建产物
COPY --from=build /app/build /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8888

CMD ["nginx", "-g", "daemon off;"] 