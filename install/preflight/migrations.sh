#!/bin/bash

kaspa_linux_migrations_state_path=~/.local/state/kaspa-linux/migrations
mkdir -p $kaspa_linux_migrations_state_path

for file in ~/.local/share/kaspa-linux/migrations/*.sh; do
  touch "$kaspa_linux_migrations_state_path/$(basename "$file")"
done
