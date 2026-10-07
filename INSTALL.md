# Install (read this first)

You are installing the Temporal Workflow Builder agents (`temporal-builder` and its
sub-agent `temporal-researcher`) onto the **current org**. Follow this file until both
agents exist and you have told the user which agent to select in a new session.

You have no extra context beyond this repository and the tools available in this session
(`cs` CLI after you are in a workspace).

## 1. Get this repository into a workspace

If the files of `https://github.com/crafting-demo/temporal-builder-agent` are **already**
in the current workspace, use them. Do not clone again. If that directory is a git
checkout of this repo, pull the latest default branch first so you install current files.

Otherwise:

1. Create a sandbox from this git repository (the URL the user pasted).
2. Target a workspace in that sandbox **immediately**. Do not stop to ask whether to open it.
3. Hand off to the workspace agent so you can run `cs` and `bash`.

This is an install, not an exploration. After the sandbox exists, keep going until the
agents are created.

Work from the repository root (the directory that contains this `INSTALL.md`).

## 2. Install

Prefer org-shared agents:

```sh
./install.sh --shared
```

If that fails because you are not allowed to manage shared agents, install personal
agents instead:

```sh
./install.sh
```

`install.sh` installs `temporal-researcher` first, then `temporal-builder`, and updates
them if they already exist. Do not create the agents by hand: the script embeds
`templates/temporal-stack.yaml` into the builder's instructions.

## 3. When you are done

Verify with `cs llm agent list` and `cs llm agent show temporal-builder --shared` (omit
`--shared` if you installed personal agents).

Tell the user:

- install is finished, and whether the agents are org-shared or personal
- to start a **new** session and select `temporal-builder`, then describe the workflow
  they want or name an existing sandbox whose script should become a workflow
- not to keep using this install session for real work
- that the sandbox created for the install is no longer needed and can be deleted
