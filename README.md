# EDD Loop — Evidence-Driven Development for Claude Code

让 Claude Code 以 **Developer → Independent Reviewer → 修复 → 复审** 的方式迭代功能变更，并用实际运行和测试证据判定完成，而不是让开发 Agent 自我宣布成功。

## 安装

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
