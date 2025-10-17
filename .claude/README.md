# Claude Code Configuration for MOAMonitoring

This directory contains Claude Code configuration and custom commands for the MOAMonitoring project.

## Available Commands

Use these slash commands in Claude Code:

- `/analyze` - Analyze the codebase structure and provide insights
- `/setup` - Set up the development environment
- `/test` - Run tests and analyze coverage
- `/review` - Review recent changes and provide feedback
- `/docs` - Generate or update project documentation

## Directory Structure

```
.claude/
├── config.json           # Project configuration
├── commands/             # Custom slash commands
│   ├── analyze.md
│   ├── setup.md
│   ├── test.md
│   ├── review.md
│   └── docs.md
├── prompts/              # Reusable prompt templates
│   └── suborchestrator-context.md
└── README.md            # This file
```

## Usage

Simply type `/` followed by the command name in Claude Code to execute custom commands.

Example:
```
/analyze
```

## Customization

You can add more commands by creating new `.md` files in the `commands/` directory with the following format:

```markdown
---
description: Brief description of what the command does
---

Your command prompt here...
```
