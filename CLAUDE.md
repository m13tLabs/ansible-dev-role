# ansible-dev-role

Ansible role for a generic Linux/macOS developer workstation base setup. It
only contains mechanics that behave identically on Linux and macOS - no
platform-specific tasks live here. It's the shared foundation used by
`mac-base`, which layers macOS-only setup (Homebrew casks, `Terminal.app`,
`.osx` defaults, etc.) on top of it.

## Project structure

```text
tasks/
  main.yml          # entry point — Setup nvm (m13tlabs.nvm), Setup Ansible, Setup dotfiles
  ansible-setup.yml  # ~/Downloads + /etc/ansible/ansible.cfg rollout, python@3 up to date
  dotfiles.yml       # .vimrc, vim package (Linux), templated bash profile
templates/
  terminal/profile.j2  # portable .bashrc - git/docker/kubectl/npm tooling, embeds nvm lines
files/
  terminal/ansible.cfg  # rolled out to /etc/ansible/ansible.cfg
  terminal/.vimrc
molecule/default/   # molecule test scenario
  molecule.yml       # docker driver config, junit report output
  converge.yml       # runs the role with test variables (dev_base_manage_python: false)
  verify.yml         # asserts nvm/node, dotfiles, ansible.cfg are correctly installed
```

## Role variables

| Variable | Default | Description |
| --- | --- | --- |
| `downloads` | `~/Downloads/` | Directory ensured to exist. |
| `dev_base_manage_python` | `true` | Set to `false` on hosts without Homebrew (e.g. plain Linux, CI containers). |

`m13tlabs.nvm`'s own variables (`nvm_user`, `nvm_group`, `nvm_working_path`,
`nvm_dest`, `nvm_version`, `nvm_node_version`, `nvm_npm_pkgs`, ...) are passed
through as-is - see that role's README for details. It's included via
`ansible.builtin.include_role` with `public: true` so its defaults (notably
`nvm_node_version`) are resolved before `dotfiles.yml` templates the bash
profile - the template embeds lines `m13tlabs.nvm` also manages, and both
need to agree on the same value.

## Testing with Molecule

Tests run inside a Debian Docker container. Docker must be running locally.
`dev_base_manage_python` is set to `false` in `molecule/default/converge.yml`
since the test container has no Homebrew.

### Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r molecule/default/requirements.txt
ansible-galaxy collection install community.docker ansible.posix
ansible-galaxy role install -r requirements.yml
ansible-galaxy collection install -r requirements.yml
```

### Run the full test cycle

```bash
molecule test
```

This runs: `prepare` → `converge` → `verify` → `destroy`. It's also what the
`CI` GitHub Actions workflow runs on every push/PR.

### Useful individual steps during development

```bash
molecule converge          # apply the role (re-runs are idempotent)
molecule verify            # run assertions only
molecule login             # open a shell in the test container
molecule destroy           # remove the container
molecule test --destroy=never  # keep container after failure for inspection
```

### JUnit test reports

After `molecule test`, XML reports are written to `molecule/default/reports/`.

## Linting

Uses `ansible-lint`.

```bash
ansible-lint
```

## Commits

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```text
<type>(<scope>): <description>

[optional body]
```

### Types

| Type | When to use |
| --- | --- |
| `feat` | New capability added to the role |
| `fix` | Bug fix in task logic |
| `chore` | CI, tooling, dependency updates — no role logic change |
| `refactor` | Code restructure with no behaviour change |
| `test` | Molecule scenarios or verify tasks only |
| `docs` | README, CLAUDE.md only |

### Scope (optional)

Use the task file name without extension: `dotfiles`, `ansible-setup`, `nvm`,
`ci`.

### Rules

- Subject line: imperative mood, no period, max 72 characters
- Do not reference internal ticket numbers in the subject line
- Breaking changes: add `!` after the type/scope and describe in the body
