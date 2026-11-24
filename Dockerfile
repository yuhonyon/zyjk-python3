# chroni-health Python 依赖环境镜像（不含业务代码）
# 构建上下文为本目录：docker build -t chroni-health-deps:latest docker/deps
# 或：make docker-deps
#
# 本目录自包含：pyproject.toml / uv.lock / README.md
# 根目录锁文件变更后请同步：make docker-deps-sync

# ---- build：装编译工具 + 依赖（asyncmy 等在部分平台无 wheel）----
FROM docker.m.daocloud.io/library/python:3.12-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/

COPY pyproject.toml uv.lock README.md ./

RUN sed -i \
      -e 's|https\?://[^/]\+/debian-security|http://mirrors.aliyun.com/debian-security|g' \
      -e 's|https\?://[^/]\+/debian|http://mirrors.aliyun.com/debian|g' \
      /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list 2>/dev/null || true \
    && apt-get update \
    && apt-get install -y --no-install-recommends gcc g++ \
    && uv sync --frozen --no-install-project --no-dev \
    && apt-get purge -y gcc g++ \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# ---- runtime：只留解释器 + .venv，无业务代码、无编译器 ----
FROM docker.m.daocloud.io/library/python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH" \
    PYTHONPATH=/app

COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/pyproject.toml /app/uv.lock /app/README.md ./

CMD ["python", "-c", "import fastapi, sqlalchemy, asyncmy, redis, arq, paho.mqtt.client, websocket; print('chroni-health-deps ok')"]
