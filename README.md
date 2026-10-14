# 作业助手：Codex / WorkBuddy

Windows本地技能与浏览器MCP配置包。支持读取课程作业、解题、填写、逐题保存核验和答案文件整理；默认最终提交由用户操作。包含对分易专用流程。

## 下载和使用

- Codex：`dist/homework-codex-plugin.zip`，按客户端支持的本地插件入口导入；不支持该入口时复制其中的`skills/homework-assistant`到Codex技能目录，由技能准备并注册MCP。
- WorkBuddy：`dist/homework-workbuddy-skill.zip`，从“技能→添加技能→上传技能”导入并启用。

首次对话：

> 使用作业助手，授权自动准备缺少的Node.js、Chrome和Playwright MCP。打开对分易让我登录，完成指定作业并逐题检查，整理题目答案，提交留给我。

客户端首次加载MCP、系统授权、连接器导入或重新连接可能需要一次用户操作。账号登录和验证码由用户完成。

## 源码

- `skills/homework-assistant/SKILL.md`：作业流程与最终检查。
- `references/duifene.md`：随机题序、稳定题目ID、多选完整集合和保存核验。
- `references/codex-setup.md`、`references/workbuddy-setup.md`：客户端安装和连接流程。
- `scripts/setup-codex.ps1`、`scripts/setup-workbuddy.ps1`：依赖准备和配置。
- `scripts/start-browser-mcp.ps1`：固定版本Playwright MCP启动器，客户端分别使用独立浏览器配置。
- `.codex-plugin/plugin.json`和`.mcp.json`：Codex插件声明。

所有references与scripts均位于`skills/homework-assistant`下。

## 验证及限制

已检查技能格式、PowerShell语法、MCP命令可运行、WorkBuddy配置合并保留已有设置及重复运行。全新电脑和真实WorkBuddy导入连接尚未进行端到端实测。包内不包含账号、Cookie、浏览器用户目录、课程答案或离线软件安装包。

首次准备需联网；使用Microsoft Playwright MCP 0.0.83。仅在获得授权时安装缺少的运行时和浏览器。按实际客户端配置位置合并，不覆盖其他连接器。

## 官方参考

- https://developers.openai.com/plugins/build/plugins
- https://github.com/microsoft/playwright-mcp
- https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Skills-Market
- https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Connector
