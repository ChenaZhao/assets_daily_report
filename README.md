# assets_daily_report

站点仓库：GitHub Pages 发布，自定义域名代理 `https://review.mktloop.top/`。
仓库里同时跑着好几条独立的日报/看板产线，各产各的、互不改动对方文件，靠 `asset/index.html` 一张导航页汇总入口。

## 目录结构

```
index.html          站点首页(Research Hub)
asset/               ← 日报发布区，三条线各管各的子目录
  ├─ macro/            宏观&资产日复盘(本产线，见下)
  ├─ equity/            A股收盘日报(权益条线)
  ├─ futures/           期货日报(期货条线)
  └─ index.html         三条线导航页，由 CI 自动生成，禁止手改
strategy/            策略层看板(周度/按需覆盖式更新，不留历史版本)
assets_daily_report/ 美国宏观场景状态
cn_v0/               中国宏观场景状态
data_factor/         数据及因子库
.github/workflows/    build-index.yml：监听发布push，自动重建 asset/index.html
```

`src/ data/ prompts/ config.py run_data.py 日线小时线.xlsx reports/` 等均为宏观条线私有源码/数据，`.gitignore` 拦截，不进仓库。

---

## 网站怎么挂载的

纯静态站点，挂在 GitHub Pages 上，没有服务器、没有仓库之外的构建产物。

- **托管源**：仓库 `ChenaZhao/assets_daily_report` 的 `main` 分支根目录直接作为 Pages 源。每次 push 到 main，GitHub 自动触发内置的 "pages build and deployment" 流程打包发布，一般一分钟内生效——这是 GitHub 自带的，和本仓库自己的 `build-index.yml`（负责重建导航页，见下文自动化章节）是两条独立流水线，互不依赖。
- **自定义域名**：根目录 `CNAME` 文件内容为 `review.mktloop.top`；DNS 侧是一条指向 `chenazhao.github.io` 的 CNAME 记录。域名验证通过后 GitHub 自动签发/续期 HTTPS 证书，仓库里不需要额外配置证书。
- **默认域名仍在**：`https://chenazhao.github.io/assets_daily_report/` 会 301 跳转到自定义域名，两者同源，`review.mktloop.top` 只是一层域名代理——**这仓库本身才是唯一的数据源**，网页问题优先当 git 问题排查，不要往域名/代理上找。
- **`.nojekyll`**：根目录空文件，关闭 Pages 默认的 Jekyll 处理。不加这个文件，中文文件名、`asset/` 这类目录可能被 Jekyll 规则误处理甚至跳过。
- **路由=目录**：没有服务端路由层，URL 路径与仓库文件路径一一对应，例如 `/asset/` 对应 `asset/index.html`，`/asset/macro/资产日复盘_2026-07-09.html` 对应仓库里同路径的文件。

---

## 功能区一：宏观 & 大类资产日复盘（`asset/macro/`）

数据 → 判断 → 发布 全自动流水线，唯一手动步骤是刷新价格 Excel。

```
Bloomberg 15分钟价格(手动) ─┐
金十快讯 / 外部RSS / Polymarket(自动) ─┤→ python run_data.py DATE
                                        │   (抓新闻+算指标+生成输入包)
                                        ↓
                          AI 消费输入包，写 reports/*.md（判断层）
                                        ↓
                          python src/build_html.py DATE
                                        ↓
                    渲染自包含HTML → push到 asset/macro/ → 飞书推送报告卡
```

- 详细步骤见 `工作流说明.md`（私有，不进仓库）。
- 报告写作规范见 `prompts/资产日复盘提示词.md`（私有）。
- Polymarket 仅作交叉验证，实时刷新但不触发其自身的飞书推送。

## 功能区二：A股收盘日报（`asset/equity/`）

权益条线自有产线，独立生成/发布，本仓库只承载成品 HTML，宏观条线脚本不触碰。

## 功能区三：期货日报（`asset/futures/`）

期货条线自有产线，同上，独立发布，互不干扰。

## 功能区四：策略层（`strategy/`）

汇总各周期性/事件驱动策略的**最新结果**看板，无历史存档需求：

- `ashare_timing.html` — A股择时（2.1.1框架·连续档），周度覆盖式替换
- `calendar_flow.html` — 事件驱动策略·美债期货日历效应
- `dc1d_trade_curve_monthly_latest_result.html` — CTA中低频趋势（Donchian Channel）
- 链接至 `assets_daily_report/`（宏观场景状态）

更新方式统一：**同名文件覆盖，不新增、不加日期后缀**。

## 功能区五：宏观场景状态（`assets_daily_report/`、`cn_v0/`）与因子库（`data_factor/`）

各自独立的状态/因子看板，按需更新，本仓库同样只承载成品页面。

---

## 自动化：导航页重建（`.github/workflows/build-index.yml`）

监听 `asset/{macro,futures,equity}/**.html` 的 push，扫目录重新生成 `asset/index.html` 的三个文件列表并提交。

- **索引是纯派生结果**：每次都从 `origin/main` 最新状态重新扫描生成，不做任何文本级合并（曾因 `rebase --autostash` 在并发push时产生冲突标记并被误提交，现已改为"拉取→重置→生成→提交，失败则整体重试"，从根源上排除冲突标记）。
- 宏观条线自身发布后也会本地防御性重建一次索引，双保险防止被别的条线的发布覆盖。

## 发布边界

- `asset/{macro,futures,equity}/*.html` 是唯一发布产物，均为自包含单文件（数据/图表库内联，离线可开）。
- 三条线只各自管自己的子目录，任何自动化都不跨目录改动。
- 源码、配置、Excel、提示词、中间数据一律 `.gitignore` 拦截，即使误用 `git add -A` 也不会泄露。
