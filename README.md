# Chroni-Health / FastAPI 慢病远程智能诊疗

慢病管理 + IoT 感知 + 数字孪生辅助分析。后端 FastAPI；前端含患者端 H5 与医生/运营后台 admin。

## 架构

```
modules/router → Service（单模块）
             → Application Case（跨模块编排）
```

约束见 [`AGENTS.md`](AGENTS.md)、详细说明见 [`docs/项目详细说明文档.md`](docs/项目详细说明文档.md)。

## 后端快速启动（本地开发）

```bash
cp .env.example .env
make up && make sync && make migrate && make seed
make seed-demo   # 可选：演示患者多源数据（孪生联调）
make run         # http://localhost:8000/docs
```

`make up` 仅启动 MySQL / Redis，不启动 API 与 nginx。

默认账号：`admin` / `admin123`（superuser + 医生档案）  
演示患者（seed-demo）：手机号 `13800009999` / 密码 `Demo1234`

## 前端（本地开发）

```bash
# 患者端 H5 → http://localhost:5173
make h5-dev
# 患者端 H5，接口走线上 chroni.91jkys.com
make h5-dev-app

# 医生/运营后台 → http://localhost:3333
make admin-dev
```

| 项目 | 说明 | 端口 |
|------|------|------|
| `frontend/h5` | 患者端（antd-mobile） | 5173 |
| `frontend/admin` | 医生/运营后台 | 3333 |

请确保 `.env` 中 `CORS_ORIGINS` 包含 `http://localhost:3333`。

## 线上单机部署（服务器只需 Docker）

代码上传到服务器后：

```bash
chmod +x start.sh && ./start.sh
```

会自动完成：

1. 没有 `.env` 时从示例生成  
2. 构建后端 API 镜像  
3. **在 Docker 内安装并编译两个前端**（`frontend/h5`、`frontend/admin`），打入 nginx 镜像  
4. 启动 MySQL / Redis / API / Nginx；API 启动时自动迁移 + 种子数据  

对外只开 **80**。服务器无需安装 Node / Python / Make。  
上传文件保存在项目目录 `uploads/`（宿主机挂载），重建镜像 / 重启容器不会丢失；勿执行 `docker compose ... down -v`（会清掉 MySQL 数据卷）。

| 路径 | 说明 |
|------|------|
| `http://<主机>/h5/` | 患者端 |
| `http://<主机>/admin/` | 管理后台 |
| `http://<主机>/api/v1/...` | 后端 API |
| `http://<主机>/docs` | OpenAPI |

默认管理员：`admin` / `admin123`  
等价命令：`docker compose -f docker-compose.prod.yml up -d --build`

生产请编辑 `.env`：修改 `JWT_SECRET_KEY`、`API_KEY_PEPPER`，并设 `ALLOW_PUBLIC_REGISTER=false`。可选演示数据：

```bash
docker compose -f docker-compose.prod.yml exec api python scripts/seed_twin_demo.py
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `make lint` / `make test` | 后端检查与测试 |
| `make seed` / `make seed-demo` | 权限种子 / 孪生演示数据 |
| `make migrate` | Alembic 升级 |
| `make deploy` / `./start.sh` | 服务器一键全栈启动 |

开发期可关：`REDIS_ENABLED=false`、`ARQ_ENABLED=false`。生产须 `ALLOW_PUBLIC_REGISTER=false`。
