# Codex Windows 首次使用

适用Windows 10/11本地Codex。此skill已附自动准备脚本与MCP启动器；插件包另外附带MCP声明。无需Chrome扩展，使用Playwright控制的独立Chrome配置，用户需在该浏览器登录。登录状态保留在本机，不打包、不读取或输出认证内容。

## 自动准备流程

1. 优先尝试已有浏览器工具。已有工具能连接目标页面时复用，不重复配置。
2. 没有工具时执行本skill的`scripts/setup-codex.ps1 -CheckOnly`检查环境。使用完整解析后的技能路径，不照搬旧电脑绝对路径。
3. 用户调用“首次配置／自动准备／完成作业”且已授权自动安装依赖时，执行`powershell.exe -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/setup-codex.ps1`。这会通过winget安装缺少的Node.js LTS和Chrome，并通过npx准备Microsoft Playwright MCP；已有软件不重装。首次调用仅表示解题、未授权安装时，说明所需安装项目并取得授权后执行。
4. 插件已启用时，其`.mcp.json`负责注册服务器，不运行`-RegisterMcp`。仅复制独立skill且未注册时，运行准备脚本加`-RegisterMcp`；通过Codex CLI添加独立名称`homework-browser`，保留其他MCP配置。已存在同名配置时先检查，不自动覆盖。
5. 安装完成后实际验证工具可见、`browser_tabs`可调用、页面快照可读取。当前会话不能热加载工具时，告知用户新建任务或重新连接一次；不得声称shell准备完成等于当前会话已连接。
6. 打开对分易正常登录入口，让用户在工具打开的Chrome中登录，然后读取目标课程和作业。既有日常Chrome的登录状态不会自动复制到独立配置。

## 适用边界

- 用户已明确授权后续首次自动配置时不要重复询问常规依赖安装；操作系统UAC、企业策略和Codex工具授权弹窗由用户处理，不绕过。
- 缺少winget、Codex CLI、网络或插件本地安装能力时，说明具体阻碍与最少用户动作。不要承诺零点击、自动安装任意第三方插件或自行重启Codex。
- 插件一次导入或独立skill首次注册可能需要重新连接。之后通常只需调用技能、正常登录和指定作业。
- 若npx下载失败，先检查网络与错误，允许修复后重试；不要擅自改代理或关闭TUN。
- MCP启动器保留stdio给协议使用，不添加打印登录信息的调试脚本。独立浏览器配置同一时刻只由一个作业MCP实例使用。
- Playwright包固定为`0.0.83`，需网络；仅包含启动配置而非离线Node/Chrome安装包。新电脑实际安装和端到端作业验证另行确认。
