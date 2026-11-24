# 智云健康慢病数字孪生管理系统 — 前端

本 README 面向后续接手的开发者与 AI，是 `frontend/` 前端代码的「地图 + 开发规则 + AI 上下文」。阅读后应能回答：代码在哪里、如何启动、如何复用、如何新增功能、哪些代码不能乱改。

> 说明：本仓库是前后端一体的 monorepo。后端为 FastAPI（`app/`、`alembic/`），本 README 只描述 `frontend/` 下的前端工程。后端约束见根目录 `AGENTS.md`。

## 1. 项目简介

智云健康慢病数字孪生管理系统，面向慢阻肺（COPD）、睡眠呼吸、血糖等慢病人群，提供患者侧健康自管（记录指标、绑定设备、查看照护计划/医生建议、问卷评估）与医生/运营侧管理后台（患者工作台、数字孪生辅助决策、设备/接入方管理、RBAC 权限体系）。

`frontend/` 下包含多个独立前端工程：

| 工程 | 定位 | 技术要点 | 端口 | 包管理 |
| --- | --- | --- | --- | --- |
| `frontend/h5` | 患者端 H5（移动端） | React 19 + antd-mobile | 3334 | npm |
| `frontend/admin` | 医生/运营管理后台 | React 19 + antd 6 + zustand | 3333 | pnpm |
| `frontend/decision-admin` | 辅助决策后台原型（mock 数据） | React 19 + antd 6 + echarts | — | npm |
| `frontend/App/HealthAndroidApp` | Android 原生宿主 App（Kotlin） | WebView 内嵌 H5 | — | Gradle |

核心生产前端是 **`h5`** 与 **`admin`**，两者均通过 `axios` 对接后端 `/api/v1`（HTTP 恒 200 的 `{ok, result/error}` 包络），是本 README 的重点。`decision-admin` 为 mock 原型、`HealthAndroidApp` 为原生壳，仅简要说明。

## 2. 技术栈

### `frontend/h5`（患者端）

| 项 | 技术 | 用途 |
| --- | --- | --- |
| Framework | React 19 | UI 框架 |
| Language | TypeScript 6 | 类型 |
| Build Tool | Vite 8 | 开发服务器 + 构建 |
| UI | antd-mobile 5 | 移动端组件库 |
| Router | react-router-dom 7 | 路由 |
| HTTP | axios 1 | 请求封装 |
| 服务端状态 | @tanstack/react-query 5 | 数据请求/缓存 |
| 客户端状态 | React Context | 仅认证状态（无 zustand/redux） |
| 样式 | 原生 CSS + CSS Variables | 设计令牌见 `styles/tokens.css` |
| Lint | oxlint | 代码检查 |

### `frontend/admin`（管理后台）

| 项 | 技术 | 用途 |
| --- | --- | --- |
| Framework | React 19 | UI 框架 |
| Language | TypeScript 6 | 类型 |
| Build Tool | Vite 8（rolldown） | 构建，产出 `build/` |
| UI | antd 6 + @ant-design/pro-components | 后台组件库 |
| Router | react-router 7 | 声明式路由 + 动态路由 |
| HTTP | axios 1 | 请求封装 |
| 服务端状态 | @tanstack/react-query 5 | 数据请求/缓存 |
| 全局状态 | zustand 5（含 persist） | auth/access/user/tabs/preferences/global |
| 样式 | Tailwind CSS 4 + antd ConfigProvider token + JSS | 主题与样式 |
| 工具库 | dayjs、ahooks、@dnd-kit、simplebar-react | 日期/hooks/拖拽/滚动条 |
| 图标 | unplugin-icons + @ant-design/icons + svgr | 图标 |
| Test | vitest + @testing-library | 单测 |
| Lint/Format | ESLint（@antfu/eslint-config）+ commitlint + lint-staged + simple-git-hooks | 规范与 git 钩子 |

> 注意：两个前端均未使用 `package.json` 中列出的所有依赖；实际以源码 import 为准。admin 的 `ky`、`nprogress` 等在模板基座中，未在业务中广泛使用。

## 3. 项目运行

所有命令以各前端目录的 `package.json` 为准。

### `frontend/h5`（npm）

```bash
cd frontend/h5
npm install
npm run dev        # http://localhost:3334，接口走本地后端
npm run dev:app    # 接口走线上 https://chroni.91jkys.com
npm run build      # tsc -b && vite build
npm run preview    # 预览产物
npm run lint       # oxlint
```

### `frontend/admin`（pnpm）

```bash
cd frontend/admin
pnpm install
pnpm dev            # http://localhost:3333
pnpm build          # NODE_OPTIONS=--max-old-space-size=8192 vite build → build/
pnpm preview
pnpm typecheck      # tsc --noEmit
pnpm lint           # eslint .
pnpm lint:fix
pnpm test           # vitest
pnpm check:circular-deps  # 循环依赖检查
```

### `frontend/decision-admin`（npm）

```bash
cd frontend/decision-admin
npm install
npm run dev
npm run build       # tsc --noEmit && vite build
npm run typecheck
```

### 环境变量

**h5**（`frontend/h5/.env.*`）：

| 变量 | 必填 | 用途 |
| --- | --- | --- |
| `VITE_API_BASE` | 否 | axios baseURL，默认 `/api/v1` |
| `DEV_PROXY_TARGET` | 否 | Vite 代理目标，默认 `http://localhost:8000` |

`.env.development` / `.env.production` 仅定义 `VITE_API_BASE=/api/v1`；`dev:app` 使用 `.env.app`，代理指向线上 `https://chroni.91jkys.com`。

**admin**（`frontend/admin/.env` / `.env.production`）：

| 变量 | 必填 | 用途 |
| --- | --- | --- |
| `VITE_API_BASE_URL` | 否 | axios baseURL，默认 `/api/v1` |
| `VITE_BASE_HOME_PATH` | 否 | 登录后默认跳转路由，`/home` |
| `VITE_GLOB_APP_TITLE` | 否 | 网站标题 |
| `VITE_APP_NAMESPACE` | 否 | zustand persist 存储前缀 |
| `VITE_ROUTER_MODE` | 否 | `hash`（生产）或 browser，见 `router/index.ts` |

> 不暴露真实 Key/Token。开发期通过 Vite proxy `/api` → `http://localhost:8000`，生产由 nginx 同域反代 `/api/v1`。

## 4. 项目目录结构

### `frontend/h5/src`

```text
src/
├── api/            # 按业务域划分的接口模块 + client.ts
├── assets/         # 静态资源
├── components/     # 通用组件（AuthGuard、health-ui）
├── layouts/        # MainLayout（底部 Tab 布局）
├── pages/          # 页面（Home/Login/Me/Consent/Screening/Devices/Records/CarePlans/Advices/Assessments）
├── routes/         # 路由定义（index.tsx）
├── stores/         # 客户端状态（auth.tsx：AuthProvider/useAuth）
├── styles/         # tokens.css（设计令牌）、tail-pages.css
├── types/          # api.ts（共享 API 类型）
├── App.tsx         # Provider 组装（QueryClient + Auth + Router）
├── main.tsx        # 入口
└── index.css       # 全局样式（引入 tokens.css）
```

### `frontend/admin/src`

```text
src/
├── api/            # 接口：chroni/（业务）、user/（登录/用户映射）、notifications/
├── assets/         # 图片/SVG
├── components/     # 通用组件（basic-table/basic-form/antd-app/access-control 等）
├── constants/      # config/options/permissions/rules/regex
├── hooks/          # 自定义 hooks（use-access/use-preferences 等）
├── icons/          # 图标（unplugin-icons + svg + 本地）
├── layout/         # 布局（container-layout/layout-root/layout-menu/layout-tabbar/widgets）
├── pages/          # 页面（home/patients/devices/system/ingest/…）
├── plugins/        # loading 插件
├── router/         # 路由（index + routes/modules|core|external + guard + extra-info + utils）
├── store/          # zustand（auth/access/user/tabs/preferences/global）
├── styles/         # 全局样式 + theme/antd
├── types/          # chroni-api.ts（共享 API 类型）、router.d.ts
├── utils/          # request/progress/search-route 等
├── app.tsx         # 主题/ConfigProvider/Router 组装
└── index.tsx       # 入口
```

关键目录职责（两个工程通用规律）：

| 目录 | 职责 |
| --- | --- |
| `api/`（h5）/ `api/chroni`（admin） | 接口函数封装，页面禁止直接 axios |
| `pages/` | 页面级组件 |
| `components/` | 可复用 UI 组件 |
| `store(s)/` | 全局状态 |
| `router/`（admin）/ `routes/`（h5） | 路由定义 |
| `types/` | 共享/API 类型定义 |
| `styles/` | 全局样式与设计令牌/主题 |

## 5. 核心文件说明

### h5

| 文件 | 作用 | 何时修改 | 注意事项 |
| --- | --- | --- | --- |
| `src/main.tsx` | 入口，处理 antd-mobile 命令式 API 与 Android 宿主标记 | 一般不修改 | React 19 + antd-mobile 兼容逻辑，勿删 `unstableSetRender` |
| `src/App.tsx` | 组装 QueryClient/Auth/Router Provider | 新增全局 Provider 时 | Provider 顺序影响 Hooks 可用范围 |
| `src/routes/index.tsx` | 全部路由与 basename | 新增页面 | 受保护的页面统一放 `AuthGuard` children 下 |
| `src/api/client.ts` | axios 实例、包络解包、登录失效跳转、全局错误提示 | 调整请求/鉴权行为 | 后端 HTTP 恒 200，业务失败在成功拦截器处理 |
| `src/stores/auth.tsx` | 认证状态（token/user/login/logout） | 认证逻辑变化 | token 存 `localStorage.h5_token` |
| `src/components/AuthGuard.tsx` | 登录 + 知情同意双重拦截 | 调整访问控制 | 豁免前缀 `['/consent','/legal']` |
| `src/layouts/MainLayout.tsx` | 底部 Tab 布局 | 调整主导航 | Android 宿主内隐藏底部 Tab |
| `src/types/api.ts` | 共享 API 类型 | 新增通用类型 | 与后端 schema 对齐 |

### admin

| 文件 | 作用 | 何时修改 | 注意事项 |
| --- | --- | --- | --- |
| `src/index.tsx` / `src/app.tsx` | 入口与主题/路由组装 | 全局 Provider 或主题 | `app.tsx` 集中 antd 主题/暗黑/色弱逻辑 |
| `src/router/index.ts` | 根路由 + browser/hash 选择 | 一般不改 | `rootRoute` + `baseRoutes` 结构 |
| `src/router/routes/modules/*.ts` | 各业务模块路由（home/patients/devices/system/org/ingest/diagnosis/account） | 新增菜单/页面 | 用 `extra-info/route-path.ts` 常量，勿写死路径 |
| `src/router/extra-info/route-path.ts` | 路由 path 唯一来源 | 改路由 path | 统一维护，避免散落 |
| `src/router/guard/auth-guard.tsx` | 登录 + 动态路由 + 角色权限校验 | 权限逻辑变化 | 代码顺序敏感，勿随意调整 |
| `src/api/chroni/client.ts` | axios 实例、包络解包、鉴权、错误提示 | 调整请求/鉴权 | token 取自 `useAuthStore` |
| `src/store/auth.ts` | 登录态（zustand persist） | 认证逻辑变化 | reset 会联动 user/access/tabs |
| `src/store/access.ts` | 动态路由/菜单 | 权限路由变化 | 与 `router.patchRoutes` 联动 |
| `src/api/user/index.ts` | 登录/用户信息 → 模板 `ApiResponse` 适配层 | 对接模板基座 | 桥接 `chroni/auth` 与后台模板 |
| `src/constants/permissions.ts` | 权限码常量 | 新增权限点 | 与后端 `Permission` 表 code 对齐 |
| `src/types/chroni-api.ts` | 共享 API 类型 | 新增通用类型 | 各业务类型多内联在 api 文件内 |

## 6. 页面与路由

### h5 路由（`src/routes/index.tsx`）

路由用 `createBrowserRouter`；`/login`、`/legal/:doc` 公开，其余包在 `AuthGuard` 下。受保护的页面又分「有底部 Tab」（`MainLayout` children：`/`、`/records`、`/devices`、`/me`）与「全屏详情页」两类。

| 路径 | 页面 | 文件 | 说明 |
| --- | --- | --- | --- |
| `/login` | 登录 | `pages/Login` | 公开 |
| `/` | 首页 | `pages/Home` | Tab |
| `/records` | 记录 | `pages/Records` | Tab |
| `/devices` | 设备 | `pages/Devices` | Tab |
| `/me` | 我的 | `pages/Me` | Tab |
| `/consent` | 知情同意 | `pages/Consent` | 未同意时强制跳转 |
| `/screening`、`/screening/result/:id` | 筛查 | `pages/Screening` | |
| `/records/glucose|spo2|bp|symptoms` | 指标录入 | `pages/Records/*Form` | |
| `/records/:kind/history`、`/records/:kind/analysis` | 历史/分析 | `pages/Records/History|MetricAnalysis` | 动态段 `:kind` |
| `/records/labs`、`/records/labs/history`、`/records/labs/:id` | 检验 | `pages/Records/Lab*` | |
| `/records/exams`、`/records/cpap`、`/records/sleep/history`、`/records/sleep/:id` | 检查/睡眠 | `pages/Records/*` | |
| `/devices/catalog`、`/devices/bind/:code` | 设备目录/绑定 | `pages/Devices/Catalog|Bind` | |
| `/me/*`（health-profile/doctor/password/deactivate/privacy/legal/care-plans/advices） | 我的子页 | `pages/Me/*` | |
| `/assessments` 及子路径 | 评估（CAT/MMRC） | `pages/Assessments/*` | |

新增 h5 页面：在 `pages/` 建目录 → 在 `routes/index.tsx` 引入并注册（受保护页面放 `AuthGuard` children 内）。

### admin 路由（`src/router/`）

路由由 `src/router/routes/modules/*.ts` 声明，path 常量统一在 `src/router/extra-info/route-path.ts`，权限码在 `src/constants/permissions.ts`。菜单/路由可前端生成或后端下发（`preferences` 中 `enableBackendAccess` / `enableFrontendAceess` 控制）。

| 模块 | 路径 | 页面 | 权限码 |
| --- | --- | --- | --- |
| 工作台 | `/home` | `pages/home` | — |
| 患者管理 | `/patients`、`/patients/:id` | `pages/patients`、`pages/patients/detail` | `patient:manage` |
| 辅助诊断 | `/diagnosis/knowledge` | `pages/knowledge` | `patient:manage` |
| 组织人员 | `/org/doctors` | `pages/doctors` | `doctor:manage` |
| 设备管理 | `/devices/models`、`/devices/bindings`、`/devices/events` | `pages/devices/*` | `iot:manage` / `device_event:manage` |
| 外部接入 | `/ingest/clients`、`/ingest/events` | `pages/ingest/*` | `ingest:manage` |
| 系统设置 | `/system/basic`、`/system/users`、`/system/roles`、`/system/permissions`、`/system/dict` | `pages/basic-settings` 等 | `settings:manage` / `user:manage` / `role:manage` / `permission:manage` / `dict:manage` |
| 个人中心 | `/account` | `pages/account` | — |
| 登录 | `/login` | `pages/login` | 白名单 |
| 异常 | `/exception/403|404|500` | `pages/exception/*` | core |
| 协议 | `/privacy-policy`、`/terms-of-service` | `pages/*-policy` | 白名单 |

新增 admin 页面：在 `pages/` 建目录 → 在 `router/extra-info/route-path.ts` 加 path 常量 → 在对应 `routes/modules/*.ts` 注册（带 `order`/`title`/`icon`/`roles`）→ 如需权限码在 `constants/permissions.ts` 添加。

## 7. 组件体系

### h5

- 通用组件少而精：`components/AuthGuard.tsx`（访问控制）、`components/health-ui/`（业务 UI 工具组件）。
- 页面组件在 `pages/`，业务子页面以子目录聚合（如 `pages/Records/GlucoseForm.tsx`）。
- 组件间数据：props 下传 + `useAuth()` 取认证态 + react-query 取服务端数据；无组件事件总线。
- 新增可复用组件放 `src/components/`，业务专属组件与页面同目录。

### admin

- 基座通用组件在 `components/`：`basic-table`、`basic-form`、`basic-button`、`basic-content`、`antd-app`、`access-control` 等，是模板提供的可复用封装，新增后台页面应优先复用。
- 业务组件与页面同目录（如 `pages/patients/detail/` 下的 `tabs/`、`DiseaseCardsPanel.tsx`、`SmartDecisionPanel.tsx` 等）。
- 布局组件在 `layout/`，业务页不直接写侧栏/顶栏。
- `components/access-control/index.ts` 用于按钮级权限控制。

组件传递数据：props；跨组件共享状态走 `store/`（zustand）；服务端数据走 react-query。

## 8. 数据与 API

两个前端共享同一后端约定：

- 后端 **HTTP 恒 200**，业务结果包在 `{ok: true, result: T}` 或 `{ok: false, message, error:{code, trace_id}}`。
- axios 响应拦截器统一解包：`ok:true` 直接返回 `result`；`ok:false` 抛错、弹全局提示（`Toast` / `message`），`code` 以 `auth.unauthorized.` 开头时清 token 并跳登录。
- 可用 `skipGlobalErrorHandler: true` 跳过全局错误提示（页面自行处理）。

### h5

- 入口：`src/api/client.ts`，`baseURL = VITE_API_BASE ?? '/api/v1'`，token 存 `localStorage.h5_token`。
- 接口按业务域拆分：`auth / me / home / records / devices / sleep / labs / exams / screening / consent / carePlans / advices / assessments`。
- 数据进入页面：页面/组件用 `@tanstack/react-query` 的 `useQuery` / `useMutation` 调用这些函数；loading 用 `isLoading`/`isPending`，错误由拦截器统一提示。

### admin

- 入口：`src/api/chroni/client.ts`，`baseURL = VITE_API_BASE_URL || '/api/v1'`，token 取自 `useAuthStore`（persist）。
- 业务接口：`src/api/chroni/*`（`users/roles/permissions/doctors/dict/patients/devices/device-events/ingest/system-settings/auth`），每个文件同时内联导出该域的 Out/Create/Update 类型。
- 模板适配层：`src/api/user/index.ts` 把登录/用户信息包装成模板基座需要的 `ApiResponse<T>`。
- Loading：页面用 react-query + `components/global-spin`；全局进度条用 `utils/progress`（NProgress）。

**约定（务必遵守）**：新增接口在 `src/api/`（h5）或 `src/api/chroni/`（admin）增加函数，**禁止**在页面组件里直接 `axios`；请求路径不要以 `/` 开头；GET/DELETE 参数走 query，POST/PUT/PATCH 走 body（与后端 AGENTS.md 强制约定一致，业务参数不进 URL path，如 `?patient_id=7`）。

## 9. 状态管理

### h5（轻量）

- 客户端状态仅认证态：`src/stores/auth.tsx` 的 `AuthProvider`/`useAuth`（React Context），暴露 `token/user/loading/login/logout/refreshMe`。
- 服务端状态统一走 `@tanstack/react-query`（`App.tsx` 中配置，`retry:1`、`refetchOnWindowFocus:false`）。
- **新功能需要状态时**：服务端数据 → react-query；跨页认证态 → `useAuth`；局部 UI 态 → 组件内 `useState`。不要引入新的全局 store 库。

### admin（zustand + react-query）

`src/store/` 下：

| store | 内容 |
| --- | --- |
| `auth.ts` | token/refreshToken，persist 持久化；`reset()` 联动 user/access/tabs |
| `user.ts` | 用户信息/角色/权限码 |
| `access.ts` | 动态路由、菜单、`isAccessChecked` |
| `tabs.ts` | 多标签页 |
| `preferences/` | 主题/布局偏好（暗黑、色弱、灰色模式等） |
| `global.ts` | 全局 UI 状态 |

服务端状态走 `@tanstack/react-query`（`components/tanstack-query` 配置，`retry:0`）。

- **新功能需要状态时**：服务端数据 → react-query；登录态/用户 → `store/auth`、`store/user`；页面级共享 → 视情况新建 zustand store（放 `store/`）；局部 UI 态 → `useState`。

## 10. 样式与 UI 规范

### h5

- 原生 CSS + CSS Variables，**无** Tailwind/SCSS/CSS Modules。
- 设计令牌集中在 `src/styles/tokens.css`（`--ch-*` 颜色/圆角/阴影，以及 `--adm-color-primary` 覆盖 antd-mobile 主色），`src/index.css` 引入。
- 业务页面级样式以 `.css` 文件与页面同目录（如 `pages/Login/login.css`、`pages/Records/history.css`）。
- 存在少量 inline style（布局类），但视觉规范（颜色/圆角）应优先用 `--ch-*` 变量。
- 新页面/组件：沿用 `.ch-*` 令牌与已有工具类（`ch-page`、`ch-nav-blue`、`ch-cta-bar` 等），保持主色 `#2a82e4` 一致。

### admin

- Tailwind CSS 4（`@tailwindcss/vite`）+ antd `ConfigProvider` token 主题 + react-jss（JSS）+ 少量 CSS Modules（如 `pages/account/index.module.css`）。
- 主题在 `src/styles/theme/antd/antd-theme.ts`（`customAntdLightTheme` / `customAntdDarkTheme`），`app.tsx` 组装暗黑/色弱/灰色/圆角/主色。
- 全局样式在 `src/styles/`（`index.css`、`global.css`、`tailwind.css`、`base.css`、`animation.css`）。
- 新页面：优先复用 `basic-table`/`basic-form` 等封装 + antd 组件，颜色/圆角走主题 token，避免硬编码。

## 11. 类型与数据模型

- **h5**：共享类型集中在 `src/types/api.ts`（`ErrorOut`/`UserOut`/`TokenOut`/`PaginatedOut` 等）；各 api 模块的入参/返回类型直接在该模块内用 `interface` 定义。
- **admin**：共享类型在 `src/types/chroni-api.ts`（`ErrorOut`/`PermissionOut`/`RoleOut`/`UserOut`/`TokenOut`/`PaginatedOut` 等）；业务类型多**内联**在对应 `src/api/chroni/*.ts`（如 `patients.ts` 里定义了 `PatientOut`、`CarePlanOut`、`HealthCockpitOut` 等大量类型）；模板侧类型在 `src/api/user/types.ts`、`src/types/router.d.ts`。
- 两者均 `strict: true`，应避免 `any`（admin 模板 guard 中少量遗留 `any`）。
- **新增数据模型**：与后端 schema 对齐。通用类型放 `types/`；业务专属类型与接口函数同文件（admin 惯例）或集中在 `types/api.ts`（h5 惯例）。

## 12. 开发规范

### 命名与文件

- 组件：PascalCase，文件 `PascalCase.tsx`（admin 布局/组件目录里也有 `index.tsx` + 小写目录组合）。
- 页面目录：kebab-case 或语义名（`pages/patients`、`pages/basic-settings`），入口多为 `index.tsx`。
- api 函数：动词开头（`listXxx`/`getXxx`/`createXxx`/`updateXxx`/`fetchXxx`）。
- Hook：`useXxx`。
- Store：`useXxxStore`（admin zustand）。

### 代码规范

- TypeScript `strict`；admin 用 ESLint（`@antfu/eslint-config`），h5 用 oxlint。
- admin import 别名 `#src/*`（`package.json` imports + `tsconfig.json` paths `"#*": ["./*"]`）；h5 用相对路径。
- 不直接 axios，走 `api/client`。
- admin 存在 commitlint（Conventional Commits）+ lint-staged + simple-git-hooks；根仓库约定 Git 提交用中文 Conventional Commits（见 `AGENTS.md`）。

## 13. 新功能开发指南

### 新增一个患者端（h5）功能页

1. 确认入口与是否受登录/知情同意保护。
2. 在 `src/pages/<Feature>/index.tsx` 建页面。
3. 在 `src/routes/index.tsx` 注册路由（受保护放 `AuthGuard` children 下）。
4. 在 `src/api/<domain>.ts`（或新建）加接口函数 + 入参/返回类型。
5. 页面用 `useQuery`/`useMutation` 接入数据（loading/error 交给拦截器与 `isLoading`）。
6. 需要共享类型放 `src/types/api.ts`。
7. 样式：新增 `.css` 与页面同目录，复用 `--ch-*` 令牌。
8. 运行 `npm run lint` + `npm run build`（含 `tsc -b`）。

### 新增一个管理后台（admin）功能页

1. 在 `src/router/extra-info/route-path.ts` 增加 path 常量。
2. 在 `src/constants/permissions.ts` 增加权限码（如需）。
3. 在 `src/pages/<feature>/index.tsx` 建页面。
4. 在 `src/router/routes/modules/<模块>.ts`（或新建模块文件并在 `routes/index.ts` 合并）注册路由，带 `order/title/icon/roles`。
5. 在 `src/api/chroni/<domain>.ts` 加接口函数（类型同文件内联）。
6. 页面用 react-query + `basic-table`/`basic-form` 复用封装。
7. 运行 `pnpm typecheck` + `pnpm lint` + `pnpm build`。

**真实示例**：admin 患者管理 = `extra-info/route-path.ts` 的 `patientsPath` → `constants/permissions.ts` 的 `PATIENT_MANAGE` → `routes/modules/patients.ts` → `pages/patients/index.tsx`（列表）与 `pages/patients/detail/index.tsx`（详情）→ `api/chroni/patients.ts`（`listPatients`/`getPatient`/`getDigitalTwin` 等）。

## 14. AI 开发指南

### 开始开发之前

按顺序阅读：

1. 本 README（定位 + 目录 + 约定）
2. 目标前端 `package.json`（脚本/依赖）
3. 入口：h5 `src/main.tsx`/`App.tsx`；admin `src/index.tsx`/`app.tsx`
4. 路由：h5 `src/routes/index.tsx`；admin `src/router/`
5. 目标页面（`src/pages/...`）
6. 相关组件（`src/components/` 或页面内组件）
7. API（h5 `src/api/`；admin `src/api/chroni/`）
8. 状态（h5 `src/stores/auth.tsx`；admin `src/store/`）
9. 类型（h5 `src/types/api.ts`；admin `src/types/chroni-api.ts` + 对应 api 文件）

### 修改代码时

- 优先复用现有组件（admin 的 `basic-table`/`basic-form` 等）、现有 hooks、现有 API 封装、现有类型。
- 不要重复实现已有能力、不无必要引入新依赖、不无必要改全局配置、不为小功能重构项目。
- 修改前先理解数据流：页面 → react-query/hooks → `api/*` → `client.ts` → 后端。
- 保持现有架构与代码风格（h5 相对路径；admin `#src/` 别名 + tab 缩进）。

### 新增文件放哪里

| 类型 | h5 | admin |
| --- | --- | --- |
| 页面 | `src/pages/<Feature>/` | `src/pages/<feature>/` |
| 通用组件 | `src/components/` | `src/components/` |
| Hook | `src/stores/` 或页面内 | `src/hooks/` |
| API | `src/api/<domain>.ts` | `src/api/chroni/<domain>.ts` |
| Store | —（仅 auth context） | `src/store/<name>.ts` |
| 类型 | `src/types/api.ts` | `src/types/chroni-api.ts` 或 api 文件内 |
| 工具函数 | 页面内或 `src/utils/`（如需要） | `src/utils/` |
| 样式 | 页面同目录 `.css` | Tailwind + antd token / 页面同目录 CSS Module |

### 需谨慎修改的核心代码

- **API Client**（`h5/src/api/client.ts`、`admin/src/api/chroni/client.ts`）：影响所有请求/鉴权/错误提示。
- **路由入口与守卫**（h5 `routes/index.tsx`+`AuthGuard`；admin `router/index.ts`+`router/guard/auth-guard.tsx`）：守卫代码顺序敏感。
- **认证/权限**（h5 `stores/auth.tsx`；admin `store/auth.ts`、`store/access.ts`、`constants/permissions.ts`）。
- **全局主题/样式**（h5 `styles/tokens.css`；admin `app.tsx` 主题、`styles/theme/`）。
- **核心布局**（h5 `layouts/MainLayout.tsx`；admin `layout/` 基座）。
- **构建配置**（各自 `vite.config.ts`、admin `package.json` 的 `imports` 别名）。
- **后端契约类型**（`types/*`）——需与后端 schema 一致。

## 15. 常见问题

- **接口 401/登录态失效**：后端 HTTP 恒 200，业务失败以 `ok:false` + `auth.unauthorized.*` 返回，由 `client.ts` 拦截处理；若未触发跳登录，检查 token key（h5 为 `h5_token`，admin 为 zustand persist `access-token`）。
- **接口报错但 HTTP 200**：正常现象，错误码在 `response.data.error.code`，全局 Toast/message 提示。
- **CORS**：开发走 Vite proxy `/api` → `:8000`，无需前端配 CORS；后端 `.env` 的 `CORS_ORIGINS` 需含 `http://localhost:3334`/`3333`。
- **admin 页面权限 403**：路由 `handle.roles` 与 `user.roles`（角色码+权限码+`admin`）不匹配；超管在 `api/user/index.ts` 放行所有业务权限码。
- **h5 命令式弹窗不出现**：React 19 + antd-mobile 兼容由 `main.tsx` 的 `unstableSetRender` 修复，勿删除。
- **admin 构建内存溢出**：已用 `NODE_OPTIONS=--max-old-space-size=8192`；若仍失败，检查大依赖/分块。
- **决策后台无数据**：`decision-admin` 为 mock 原型（`mock/` + `vite-plugin-mock`），不接真实后端。

## 16. 构建与部署

- **构建**：h5 `npm run build`（`tsc -b && vite build`）；admin `pnpm build`（`vite build`，产出 `build/`，`sourcemap:false`，`react`/`antd` 单独分块）。
- **产出与静态资源**：h5 默认 `dist/`；admin `build/`。
- **部署**：根仓库由 `start.sh` / `docker-compose.prod.yml` 在 Docker 内安装编译两个前端并打入 nginx 镜像，对外只开 80：`/h5/` 患者端、`/admin/` 后台、`/api/v1/` 后端。admin 生产用 `VITE_ROUTER_MODE=hash` 适配 `/admin` 子路径。
- **环境变量**：见第 3 节；生产 nginx 同域反代 `/api/v1`，前端 baseURL 保持 `/api/v1`。
- 具体 CI/CD 与主机信息：⚠️ 待确认（根仓库 `.github/workflows/ci.yml` 存在，但前端专属部署流水线细节需结合实际基础设施确认）。

## 17. 项目架构图

```mermaid
flowchart TD
    subgraph H5["frontend/h5 患者端"]
        H5Entry[main.tsx] --> H5App[App.tsx]
        H5App --> H5Router[router/index.tsx]
        H5Router --> H5Guard[AuthGuard]
        H5Guard --> H5Layout[MainLayout]
        H5Layout --> H5Pages[pages/*]
        H5Pages --> H5Api[api/*]
        H5Api --> H5Client[api/client.ts]
        H5App --> H5Auth[stores/auth.tsx]
        H5App --> H5Query[react-query]
    end

    subgraph Admin["frontend/admin 管理后台"]
        AdminEntry[index.tsx] --> AdminApp[app.tsx]
        AdminApp --> AdminRouter[router/index.ts]
        AdminRouter --> AdminGuard[guard/auth-guard.tsx]
        AdminGuard --> AdminAccess[store/access.ts]
        AdminRouter --> AdminPages[pages/*]
        AdminPages --> AdminApi[api/chroni/*]
        AdminApi --> AdminClient[api/chroni/client.ts]
        AdminApp --> AdminStore[store/auth|user|access|tabs|preferences]
        AdminApp --> AdminQuery[react-query]
    end

    H5Client --> Backend["FastAPI /api/v1"]
    AdminClient --> Backend
```

> `decision-admin` 为独立 mock 原型（页面 → `api/*` + `mock/*`），不接真实后端；`HealthAndroidApp` 以 WebView 承载 h5（UA 标记 `ChroniHealthApp`，h5 据此隐藏底部 Tab）。
