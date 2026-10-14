# WorkBuddy Windows 适配

## 首次使用

WorkBuddy支持从“技能→添加技能→上传技能”导入本地技能包。连接器页面的“自定义连接器”可添加MCP服务。UI入口以现场版本为准，不能把Codex插件manifest直接当WorkBuddy插件导入。

1. 先测试当前可用浏览器工具。已有连接可读目标页面时直接复用。
2. 缺少工具时执行`scripts/setup-workbuddy.ps1 -CheckOnly`。在用户授权首次自动安装和配置的范围内，运行不带CheckOnly的脚本，准备Node.js、Chrome及固定版本Playwright MCP。通用依赖准备复用`setup-codex.ps1`，此模式不注册Codex、不要求Codex CLI。
3. 从WorkBuddy自定义连接器／MCP设置现场确认它使用的JSON配置位置。已有确定路径时传`-McpConfigPath <绝对路径>`；脚本备份并只合并homework-browser，不输出其他连接器配置。不能仅根据文件名或旧电脑习惯认定配置有效。
4. 未能确认配置位置时，脚本生成`generated/workbuddy-mcp.json`，用WorkBuddy正常配置入口添加其中的MCP声明。可以在用户授权且当前可用UI控制允许时自动操作，否则告诉用户需要完成的一次导入动作，不虚构“已经注册”。不要覆盖整个现有配置。
5. 启用连接器并实际验证工具列表、标签页和页面快照。必要时让用户重新连接或新建任务一次；不擅自重启软件。
6. 通过该MCP打开对分易浏览器，让用户正常登录并指定课程作业。保留登录的本地独立目录为`%LOCALAPPDATA%\WorkBuddyHomework\browser-profile`，与Codex目录分开；无需Chrome扩展，不读取或输出Cookie等凭据。

## 后续作业

读取duifene.md，按题目ID对应题序、逐题确认保存请求和服务器回读、整理答案文件；默认提交留给用户。浏览器不可用时不启动限时作业。

此包不含WorkBuddy程序，不保证不同版本均可热加载工具。首次技能导入、系统UAC、WorkBuddy授权以及无法自动操作的配置入口可能需用户处理。当前仅完成格式、脚本和隔离配置合并检查；真实WorkBuddy客户端的导入和浏览器连接尚未实测。

官方资料：

- https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Skills-Market
- https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Connector
- https://www.codebuddy.cn/docs/ide/User-guide/MCP （WorkBuddy连接器文档链接的MCP配置说明）
