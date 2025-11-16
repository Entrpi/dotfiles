# SSH Configuration

SSH client configuration for use with chezmoi.

## What's Here

- `private_config.tmpl` - SSH client configuration template

## SSH Keys

**SSH keys are managed in the `.personal/` private submodule**, not in this main dotfiles repository.

This separation ensures:
- Main dotfiles repo can be safely shared/forked
- Encrypted SSH keys stay in your private personal profile
- Better security through separation of concerns

## Key Management

SSH keys are automatically managed when you run `chezmoi apply`:

1. **If `.personal/` submodule exists with encrypted keys**: Keys are decrypted and restored to `~/.ssh/`
2. **If no keys exist**: New ed25519 key pair is generated automatically

## Adding Key to GitHub

```bash
# Show your public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub using gh CLI
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
```

## Files

- `~/.ssh/config` - SSH client configuration (from this directory)
- `~/.ssh/id_ed25519` - Private key (managed by `.personal/` submodule)
- `~/.ssh/id_ed25519.pub` - Public key (managed by `.personal/` submodule)

## See Also

See the main [README.md](../README.md) for complete documentation on the personal profile system and SSH key encryption.
