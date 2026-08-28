# ansible-dev-role

[![Ansible Galaxy](https://img.shields.io/badge/galaxy-m13tlabs.dev-660198?logo=ansible)](https://galaxy.ansible.com/ui/standalone/roles/m13tlabs/dev/)
[![CI](https://github.com/m13tLabs/ansible-dev-role/actions/workflows/ci.yml/badge.svg)](https://github.com/m13tLabs/ansible-dev-role/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

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

- Rolls out `.vimrc` and a generic bash profile (`.bashrc`/`.profile`) with
  portable git/docker/kubectl/npm tooling - no macOS-only paths or binaries.
- Installs Node.js via [m13tlabs.nvm](https://github.com/m13tLabs/ansible-nvm-role).

## Requirements

- Ansible >= 2.5
- The `community.general` collection (for the `homebrew` module) and the
  `m13tlabs.nvm` role - both declared in [requirements.yml](requirements.yml):

  ```console
  ansible-galaxy role install -r requirements.yml -f
  ansible-galaxy collection install -r requirements.yml
  ```

# Usage

<!-- ANSIBLE DOCSMITH MAIN START -->

## Role variables<a id="variables"></a>

The following variables can be configured for this role:

| Variable | Type | Required | Default | Description (abstract) |
|----------|------|----------|---------|------------------------|
| `dev_base_manage_python` | `bool` | No | `true` | Set to `false` on hosts without Homebrew (e.g. plain Linux, CI containers). |
| `downloads` | `str` | No | `"~/Downloads/"` | Configuration value for downloads |

### `dev_base_manage_python`<a id="variable-dev_base_manage_python"></a>

[*⇑ Back to ToC ⇑*](#toc)

Set to `false` on hosts without Homebrew (e.g. plain Linux, CI containers).

- **Type**: `bool`
- **Required**: No
- **Default**: `true`



### `downloads`<a id="variable-downloads"></a>

[*⇑ Back to ToC ⇑*](#toc)

Configuration value for downloads

- **Type**: `str`
- **Required**: No
- **Default**: `"~/Downloads/"`




<!-- ANSIBLE DOCSMITH MAIN END -->


# Testing

Tests run via [molecule](https://molecule.readthedocs.io/) against a Debian
container, exercising the role's actual tasks (ansible.cfg/dotfiles
rollout, plus a real `m13tlabs.nvm` install/verify) rather than just a syntax
check. `dev_base_manage_python` is set to `false` in
`molecule/default/converge.yml` since the test container has no Homebrew.

```console
pip install -r molecule/default/requirements.txt
ansible-galaxy collection install community.docker ansible.posix
ansible-galaxy role install -r requirements.yml
ansible-galaxy collection install -r requirements.yml
molecule test
```

This is also what the `CI` job in
[.github/workflows/ci.yml](.github/workflows/ci.yml) runs on every push and
pull request.
