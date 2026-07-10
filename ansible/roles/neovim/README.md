# Neovim Ansible role

This role:

- installs a pinned, checksum-verified official Neovim release under `/opt`;
- installs pinned Node.js and Go runtimes needed by Mason package installers;
- installs a checksum-verified tree-sitter CLI for `tree-sitter-manager.nvim`;
- installs build/runtime prerequisites used by Lazy and Mason;
- clones or updates the Neovim configuration as the target user;
- runs blocking headless plugin and language synchronisation;
- validates the language registry before completing.

## Use

Keep `neovim` in `ansible/site.yml`:

```yaml
- name: Configure system
  hosts: local
  become: true
  vars:
    workstation_user: daniel
  roles:
    - common
    - neovim
```

Setting `workstation_user` explicitly is recommended. It avoids ambiguity when the playbook is launched through `sudo`, locally, or over SSH.

Run from the dotfiles repository:

```sh
ansible-playbook -i ansible/inventory.ini ansible/site.yml --ask-become-pass
```

## Important variables

- `neovim_config_version`: branch, tag, or commit to deploy. Use a tested commit SHA for immutable machine builds.
- `neovim_version`, `node_version`, `go_version`, `tree_sitter_cli_version`: pinned infrastructure versions.
- `neovim_backup_unmanaged_config`: backs up a non-Git `~/.config/nvim` before cloning.
- `neovim_bootstrap_plugins` / `neovim_bootstrap_languages`: permit skipping headless synchronisation while debugging.

When changing a pinned runtime version, update the corresponding architecture-specific SHA-256 values in `defaults/main.yml` from the upstream release's published checksums.
