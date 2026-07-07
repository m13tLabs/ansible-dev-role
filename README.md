# mare.dev

Generic Linux/macOS developer workstation base setup. This role only contains
mechanics that behave identically on Linux and macOS - it has no
platform-specific tasks. It's the shared foundation used by
[mac-base](https://gitlab.m13t.de/infrastructure/mac-base), which layers
macOS-only setup (Homebrew casks, `Terminal.app`, `.osx` defaults, etc.) on
top of it.

## What it does

- Rolls out a project-wide `/etc/ansible/ansible.cfg` and ensures a downloads
  directory exists.
- Ensures `python@3` is up to date via Homebrew (skip on hosts without brew,
  see [Role Variables](#role-variables)).
- Rolls out a sudoers configuration (validated with `visudo` before it's
  written).
- Rolls out `.vimrc` and a generic bash profile (`.bashrc`/`.profile`) with
  portable git/docker/kubectl/npm tooling - no macOS-only paths or binaries.
- Installs Node.js via [mare.nvm](https://gitlab.m13t.de/infrastructure/ansible-nvm-role).

## Requirements

- Ansible >= 2.5
- The `community.general` collection (for the `homebrew` module) and the
  `mare.nvm` role - both declared in [requirements.yml](requirements.yml):

  ```console
  ansible-galaxy role install -r requirements.yml
  ansible-galaxy collection install -r requirements.yml
  ```

## Role Variables

| Variable | Default | Description |
| - | - | - |
| `downloads` | `~/Downloads/` | Directory ensured to exist. |
| `dev_base_manage_python` | `true` | Set to `false` on hosts without Homebrew (e.g. plain Linux, CI containers). |
| `sed_path` | auto-detected | Path to `sed`, used by the sudoers task; only computed if left undefined. |

`mare.nvm`'s own variables (`nvm_user`, `nvm_group`, `nvm_working_path`,
`nvm_dest`, `nvm_version`, `nvm_node_version`, `nvm_npm_pkgs`, ...) are passed
through as-is - see that role's README for details.

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: mare.dev
      vars:
        dev_base_manage_python: false # no Homebrew on this host
```

## Testing

Tests run via [molecule](https://molecule.readthedocs.io/) against a Debian
container, exercising the role's actual tasks (ansible.cfg/sudoers/dotfiles
rollout, plus a real `mare.nvm` install/verify) rather than just a syntax
check. `dev_base_manage_python` is set to `false` in
`molecule/default/converge.yml` since the test container has no Homebrew.

```console
pip install -r molecule/default/requirements.txt
ansible-galaxy collection install community.docker ansible.posix
ansible-galaxy role install -r requirements.yml
ansible-galaxy collection install -r requirements.yml
molecule test
```

This is also what the `Molecule test` job in `.gitlab-ci.yml` runs on every
pipeline.

## License

MIT

## Author

Martin Reinhardt
