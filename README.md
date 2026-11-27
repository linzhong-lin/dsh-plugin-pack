# dsh-plugin-pack · DSH 插件合集（一条链接装齐）

这是 「霖栗」 那台机器上装的一整套 DSH 插件的清单 + 一键安装脚本。
**不含任何插件源码**，只做两件事：列出装什么、用 `dsh plugin add` 把它们装上。版权都属于各自作者。

实测环境：DeepSeek Harness **0.2.2-rc.5**、Windows 11 x64、profile `desktop`。

---

## 一条命令装齐（Windows）

```powershell
$p = "$env:TEMP\dsh-pack.ps1"; irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

非要一行 `iex` 也行（脚本带 BOM，`iex` 会把 BOM 当命令名报一行错，所以先把 BOM 去掉）：

```powershell
iex ((irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1) -replace [string][char]0xFEFF, '')
```

网络抽风打不开 raw 的话，换成这两个地址之一，内容一样：

```powershell
$p = "$env:TEMP\dsh-pack.ps1"; irm https://github.com/linzhong-lin/dsh-plugin-pack/raw/main/install.ps1 -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

```powershell
$p = "$env:TEMP\dsh-pack.ps1"; irm https://gh-proxy.com/https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

再不行（PowerShell 报 `基础连接已经关闭` / `无法连接到远程服务器`，多半是本机代理或 TLS 的问题），直接用 curl 拉下来交给 PowerShell：

```powershell
curl.exe -sL https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 | powershell -NoProfile -ExecutionPolicy Bypass -Command -
```

想改配置档 / 跳过某些插件（先设环境变量，再跑同一行）：

```powershell
$env:DSH_PROFILE = 'desktop'; $env:DSH_PACK_SKIP = 'dsh-pet,dshmarket'
$p = "$env:TEMP\dsh-pack.ps1"; irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

只装核心（跳过宠物、挂件、市场、统计这类可选项）：

```powershell
$env:DSH_PACK_CORE = '1'
$p = "$env:TEMP\dsh-pack.ps1"; irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

只想看会执行什么、不真装：

```powershell
$env:DSH_PACK_DRY = '1'
$p = "$env:TEMP\dsh-pack.ps1"; irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
```

把脚本存到本地跑（这种写法可以直接带参数）：

```powershell
irm https://raw.githubusercontent.com/linzhong-lin/dsh-plugin-pack/main/install.ps1 -OutFile install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Profile desktop -Skip dsh-pet -CoreOnly -DryRun
```

脚本会先找 `dsh` 命令；找不到就用 `npx -y @deepseek-ai/dsh@latest`，两者都没有就打印插件名，让你在 DSH 的「插件」页手动粘贴。

> 改完脚本看不到新内容？raw.githubusercontent 和 jsdelivr 都有几分钟 CDN 缓存，`?v=` 也刷不掉。等几分钟，或者用上面 `github.com/.../raw/main/...` 那个地址（不走 jsdelivr），或者用 curl 那条。

---

## 手装（不想跑脚本）

```powershell
dsh plugin --profile desktop add dsh-soul-md dsh-context billion-context dsh-genui dsh-speak-up "@liustack/modlens" dsh-token-diet dsh-whale-widget dshmarket dsh-pet
```

装了 dshmarket 之后，也可以直接在 DSH 里的插件市场里点。

---

## 清单

| 插件 | 身份 | 干什么 | 实测版本 | 必须 |
| --- | --- | --- | --- | --- |
| **dsh-soul-md** | 核心 | 人设卡 + 分层长期记忆，`soul:persona` / `soul:memory` 注入每个会话；设置页写在 插件 → dsh-soul-md | 0.12.5 | ✓ |
| **dsh-context** | 核心 | 上下文洞察：窗口占用、缓存命中、折叠历史；带 `/context` 命令 | 0.87.0 | ✓ |
| **billion-context** | 核心 | 代替内置 compaction 的压缩层：旧对话折成可搜索、可 `decompress` 的摘要块 | 0.1.216 | ✓ |
| **dsh-genui** | 核心 | 生成式 UI：回答里直接出图表 / 表单 / 计算器卡片 | 0.3.4 | ✓ |
| **dsh-speak-up** | 核心 | 主动搭话：没人聊的时候自己起话头，间隔/概率可调，掷骰子不花模型 | 0.3.3 | ✓ |
| **@liustack/modlens** | 核心 | 给纯文本模型加视觉：`modlens_read_image` 读截图 / 照片 / 扫描件 | 3.27.5 | ✓ |
| dsh-token-diet | 可选 | Token 统计与按会话预算，预算烧完就停任务 | 0.1.0 | |
| dsh-whale-widget | 可选 | 右下角余额小鲸鱼：余额 / 今日已用 / 峰谷定价 | 0.4.2 | |
| dshmarket | 可选 | 插件市场，DSH 内浏览、搜索、一键装 | 1.77.1 | |
| dsh-pet | 可选 | 蓝色大肥鱼桌宠（解包 79 MB，依赖带 openai / @anthropic-ai/sdk） | 0.4.9 | |
| ~~dsh-at-file~~ | 默认跳过 | `@path` 引用文件；**0.6.3 在 0.2.2-rc.5 上激活会报 `@deepseek-ai/dsh-settings` 没有 `settingsNamespace` 导出** | 0.6.3 | |

机器可读的清单位于 [`plugins.json`](plugins.json)（含每个插件的 knownGood 版本、主页、是否可选）。

---

## 装完要做的三件事

1. **重启 DSH**（或刷新窗口），插件才会加载；
2. 打开「插件」页，确认它们都是启用状态；红字报错就贴日志里那行 `did not activate` 搜；
3. 人设写在 **dsh-soul-md 的设置页**里，不要塞进系统提示词——它管的是所有会话（包括插件自己开的会话）。

---

## 已知坑

- **dsh-at-file 0.6.3 装得上、激活不了**：`failed to import: SyntaxError: The requested module '@deepseek-ai/dsh-settings' does not provide an export named 'settingsNamespace'`。它只有这一个版本，等作者跟进；脚本默认跳过。
- **billion-context 会接管压缩层**：它 override 掉内置 `compaction-basic`。装了之后别再装别的压缩插件，不然两套折叠打架。
- **modlens 需要视觉通道**：没配 provider 时调用会直接报 `No vision provider is set up on this machine`。要么装 Antigravity CLI，要么 `modlens config set gemini.apiKey ...`。
- **@liustack/modlens 带 `@`**：PowerShell 里手敲要加引号 `"@liustack/modlens"`，否则被当成 splatting。
- 大面积装插件时 pnpm 会重解整棵依赖树，**别在生成图/语音的时候装**——宿主重启会把正在跑的请求掐断（`连不上生图接口：fetch failed` 多半是这个原因）。

---

## 卸载

```powershell
dsh plugin --profile desktop remove dsh-pet
```

或者在「插件」页里点卸载。配置文件一般留在 `~/.dsh/<插件名>/`，要彻底清就自己删。

---

## 另外几个仓库（不在本清单里）

这几个是本机自研/改写版，单独发：

- [dsh-qqbot](https://github.com/linzhong-lin/dsh-qqbot) —— QQ 频道：OpenQQ 桥接、克隆声线、表情包、日记与记忆、面板登录闸门
- [dsh-daily-schedule](https://github.com/linzhong-lin/dsh-daily-schedule) —— 每日日程（改写版：接入聊天流水 / 日记 / 长期记忆）
- [dsh-image-studio](https://github.com/linzhong-lin/dsh-image-studio) —— 生图（改写版：重试与报错加固）

**B站养鱼插件**（`dsh-bili-whale`，上游是 ALTERSSSS 的 MIT 项目，不在 npm 上）：

```powershell
dsh plugin --profile desktop add "dsh-bili-whale@https://github.com/Alterssss/dsh-bili-whale/tarball/main"
```

它要 B站 cookie 和一个 ffmpeg（抽帧用），不配也能跑文字部分。

---

## 版权

`install.ps1` / `plugins.json` / 本 README：MIT，随便改。
清单里的每个插件版权归各自作者，本仓库**不复制、不再分发**它们的代码，只给 `dsh plugin add` 的包名。
