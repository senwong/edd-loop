# EDD Loop — Evidence-Driven Development for Claude Code

让 Claude Code 以 **Developer → Independent Reviewer → 修复 → 复审** 的方式迭代功能变更，并用实际运行和测试证据判定完成，而不是让开发 Agent 自我宣布成功。

## 安装

### 让 Agent 自动安装（推荐）

把下面这段提示词粘贴到具备本机终端执行权限的 **Claude Code 或 Codex** 中。Agent 将读取仓库内容、执行安装、检查结果；无需你逐条输入命令。

```text
请帮我自动安装以下 GitHub 仓库的 Claude Code Skill：
https://github.com/senwong/edd-loop

目标：全局安装到当前用户的 ~/.claude，使 /edd-loop 和两个子 Agent 可在不同项目使用。

请自己调用终端工具，按以下流程执行，不要仅输出操作说明：
1. 检查 git、HOME、~/.claude 及当前文件权限，确认可以安装。
2. 在安全的临时目录克隆仓库，并读取 README.md、install.sh、
   skills/edd-loop/SKILL.md 和两个 Agent 配置，确认安装来源与脚本行为。
3. 首次安装时执行 bash install.sh --user。
4. 如果检测到已安装的同名 Skill 或 Agent，先检查差异并保留已有配置；
   对确认属于本仓库的旧版本，可以使用 bash install.sh --user --force
   自动备份后更新。遇到来源不明的同名配置或冲突时不要擅自覆盖。
5. 验证以下文件确实存在且内容与仓库版本一致：
   ~/.claude/skills/edd-loop/SKILL.md
   ~/.claude/skills/edd-loop/references/protocol.md
   ~/.claude/agents/edd-developer.md
   ~/.claude/agents/edd-reviewer.md
6. 检查 Skill 和 Agent 的 YAML frontmatter 是否完整、有效。
   如有可用的 Claude Code 命令，可进一步检查 Skill 是否被识别；
   没有实际执行的检查不得宣称通过。
7. 安装成功后，清理本次创建的临时目录，不修改无关配置。
8. 最终报告安装位置、Git commit、已执行的验证、遗留问题，
   并提示我开启新的 Claude Code 会话后使用 /edd-loop <需求>。

请自主解决可处理的错误并重试；如遇必要的权限确认，正常请求授权，
不要绕过权限保护或执行未经检查的远程脚本。现在开始实际安装。
```

> Agent 必须具有访问本机文件系统和执行终端命令的能力。Claude Code 可能仍要求你批准工具调用。安装到磁盘不等于验证了完整双 Agent 运行；建议新开 Claude Code 会话进行一次实际任务验证。

### 手动安装

```bash
git clone https://github.com/senwong/edd-loop.git
cd edd-loop
bash install.sh --user
```

这会将 Skill 安装到 `~/.claude/skills/edd-loop/`，并将两个子 Agent 安装到 `~/.claude/agents/`，可在本机多个项目中复用。

仅安装到单个项目：

```bash
bash install.sh --project /path/to/your/project
```

安装器默认拒绝覆盖已有同名文件。显式传入 `--force` 才会备份原文件并安装。它不会修改你的业务项目源码。

## 使用

在目标项目启动 Claude Code，执行：

```text
/edd-loop 修改登录后导航逻辑，检查受影响调用方，运行相关测试及回归验证。
```

可选：先用 Claude Code 的 `/goal` 设置外层目标，再执行 `/edd-loop`；`/goal` 不是硬性保证，不能替代独立 Reviewer 的实际测试。`/loop` 是定时重复机制，不用于这里的即时开发闭环。

## 工作方式

1. Coordinator（当前主会话）建立验收标准、基线和迭代上限。
2. 调用 `edd-developer` 独立子 Agent：分析、修改、运行自测。
3. 调用**全新** `edd-reviewer` 独立子 Agent：从原始需求与当前工作树重新查证并执行测试，**不传 Developer 的分析报告作为先验**。
4. 依据证据输出 `PASS / FAIL / INCONCLUSIVE / BLOCKED`；失败则返回 Developer，并重启新 Reviewer。默认最多 8 轮。
5. 仅在最新版本的验收和必要验证通过时正常结束；否则如实报告未完成或阻塞。

## 目录

```text
skills/edd-loop/SKILL.md             调度 Skill
skills/edd-loop/references/protocol.md 审核与证据协议
agents/edd-developer.md              开发子 Agent
agents/edd-reviewer.md               独立审核子 Agent
install.sh                            安装器
tests/test-install.sh                 安装器测试
```

## 边界与安全

- **Reviewer 的工具清单不含 Edit / Write**，但 Bash 测试或工具副作用仍可能写文件；这不是系统级沙盒。若需要强制只读审计，应另用容器、隔离权限或 CI runner。
- 审核必须覆盖未提交修改和未跟踪文件；仅审核 `HEAD` 会漏掉本轮代码。
- 默认不自动 `git add`、`commit`、`reset`、`push`、`deploy`，也不覆盖本地用户改动。
- Agent 的调用和继续执行依赖 Claude Code 当前版本、权限、令牌与上下文；Skill 是工作流提示，不是永不终止的外部守护进程。
- 对关键跨仓影响，以明确可运行的消费路径和实测证据为准；仅包依赖、文本搜索或静态猜测不足以确认。

## 参考

- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code /goal](https://code.claude.com/docs/en/goal)

License: MIT
