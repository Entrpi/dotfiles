# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- **ZSH Configuration**: Enhanced shell with oh-my-posh prompt (devious-diamonds theme)
- **Plugin Management**: Antidote for fast, reliable ZSH plugin loading
- **Shell History**: Atuin for better command history (local-only, no cloud sync)
- **Nerd Fonts**: Monaco patched with Nerd Font glyphs for proper icon rendering
- **Alias Management**: Dedicated `.aliases` file with management functions
- **Auto-Configuration**: Automatic Homebrew, font installation, and iTerm2 setup
- **Personal Profile**: Optional private submodule for your personal data and encrypted secrets

## Quick Start

### New Mac Setup

```bash
# Install chezmoi and apply dotfiles (replace <your-github-username> with your GitHub username)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>/dotfiles
```

**First-time setup prompts:**

When you first initialize the dotfiles, you'll be asked for:
- **Full name**: Used for git commits
- **Email address**: Used for git commits and SSH keys
- **GitHub username**: Used for git and GitHub CLI configuration

These values are stored locally in `~/.config/chezmoi/chezmoi.toml` and used to template your configuration files.

**What happens automatically:**
1. Install Homebrew (if needed)
2. Install all packages from Brewfile
3. Install and configure Monaco Nerd Font
4. Apply all dotfiles and configurations
5. If `.personal/` submodule exists with age key, decrypt SSH keys automatically

**After first setup:**
- Run `.scripts/create-personal-profile.sh` to create your personal profile (optional but recommended)
- Or use the dotfiles as-is with local configuration only

### Manual Setup

```bash
# Install chezmoi
brew install chezmoi

# Initialize and apply dotfiles (replace <your-github-username>)
chezmoi init https://github.com/<your-github-username>/dotfiles.git
chezmoi apply
```

## What Gets Installed

### Homebrew Packages

See `~/.Brewfile` for the complete list. Key packages:

**Essential Tools:**
- chezmoi - Dotfile manager
- neovim - Modern vim
- curl - HTTP client

**Shell Enhancement:**
- oh-my-posh - Prompt theme engine
- antidote - ZSH plugin manager
- atuin - Better shell history

**Development:**
- python@3.14
- podman

### Configuration Files

- `~/.zshrc` - Main ZSH configuration
- `~/.aliases` - Aliases and custom functions
- `~/.zsh_plugins.txt` - Antidote plugin list
- `~/.config/atuin/config.toml` - Atuin configuration
- `~/.Brewfile` - Homebrew package list

### Fonts

- Monaco Nerd Font Mono (automatically installed to `~/Library/Fonts/`)
- iTerm2 automatically configured to use the patched font

## ZSH Features

### Included Plugins

- `zsh-autosuggestions` - Fish-like command suggestions
- `zsh-completions` - Additional completion definitions
- `zsh-syntax-highlighting` - Syntax highlighting for commands
- `zsh-history-substring-search` - Better history search
- `fast-syntax-highlighting` - Faster syntax highlighting
- `zsh-you-should-use` - Reminds you of your aliases
- `zsh-z` - Directory jumping based on frecency
- Oh-My-Zsh plugins: git, docker, docker-compose, colored-man-pages, command-not-found, extract, sudo, cp, z

### Alias Management Functions

- `alias-edit` - Edit aliases in nvim and auto-reload
- `alias-reload` - Reload aliases
- `alias-list` - List all defined aliases
- `alias-search <keyword>` - Search for aliases

### Utility Functions

- `mkcd <dir>` - Create directory and cd into it
- `extract <file>` - Extract any archive format (tar, zip, gz, etc.)
- `note <text>` - Quick note taking (appends to ~/.notes.txt)
- `notes` - Edit notes file in nvim

## Customization

### Editing Configuration

```bash
# Edit any file managed by chezmoi
chezmoi edit ~/.zshrc

# Or use the alias helper
alias-edit  # Opens ~/.aliases in nvim and reloads on save
```

### Adding New Files

```bash
# Add a single file to chezmoi
chezmoi add ~/.gitconfig

# Add an entire directory
chezmoi add ~/.config/nvim

# View what's currently managed
chezmoi managed
```

### Updating Brewfile

```bash
# After installing new packages with brew
cd ~/.local/share/chezmoi
brew bundle dump --file=dot_Brewfile --force

# Commit the changes
git add dot_Brewfile
git commit -m "Update Brewfile: add <package-name>"
```

### Patching Custom Fonts

```bash
# Navigate to chezmoi directory
chezmoi cd

# Run the font patcher on any font
.scripts/patch-font.sh /path/to/your/font.ttf

# Font will be output to ~/Library/Fonts/
```

## Shell History (Atuin)

Atuin provides enhanced shell history with:
- Fuzzy search (Ctrl+R)
- Directory-specific filtering with up arrow
- No cloud sync (configured for local-only use)
- 100,000 command history limit
- Smart filtering (ignores ls, cd, pwd, exit by default)

## Structure

```
~/.local/share/chezmoi/
├── README.md                                         # This file
├── .chezmoi.toml.tmpl                                # Chezmoi config (checks for .personal/data.yaml)
├── .gitignore                                        # Git ignore (.personal/ is ignored in main repo)
├── .gitmodules                                       # Git submodules (.personal linked here)
│
├── .personal/                                        # Personal profile submodule (PRIVATE REPO)
│   ├── data.yaml                                     # Your name, email, GitHub username
│   ├── private_dot_ssh/
│   │   ├── encrypted_private_id_ed25519.age         # Encrypted SSH private key
│   │   └── id_ed25519.pub                           # SSH public key
│   ├── .gitignore                                    # Prevents age key from being committed
│   ├── .chezmoiignore                                # Tells chezmoi what to ignore
│   └── README.md                                     # Personal profile documentation
│
├── .scripts/
│   ├── create-personal-profile.sh                    # Wizard to create personal profile
│   └── patch-font.sh                                 # Font patching utility
│
├── .fonts/
│   ├── MonacoNerdFontMono-Regular.ttf               # Patched Monaco Nerd Font
│   └── README.md                                     # Font documentation
│
├── dot_Brewfile                                      # Homebrew packages
├── dot_zshrc                                         # ZSH configuration
├── dot_aliases                                       # Aliases and functions
├── dot_zsh_plugins.txt                               # Antidote plugins
├── dot_gitconfig.tmpl                                # Git config (uses {{ .name }}, {{ .email }})
├── dot_gitignore_global                              # Global gitignore
│
├── dot_config/
│   └── atuin/
│       └── config.toml                               # Atuin config (local-only history)
│
├── private_dot_ssh/
│   ├── README.md                                     # SSH key documentation
│   └── private_config.tmpl                           # SSH client config
│
├── run_once_before_05-install-homebrew.sh.tmpl      # Homebrew installation
├── run_once_before_10-install-nerd-fonts.sh.tmpl    # Font installation
├── run_once_before_15-setup-ssh.sh.tmpl             # SSH key generation (if needed)
└── run_once_after_90-setup-personal-profile.sh.tmpl # Load personal profile, decrypt SSH keys
```

## Updating

### Update Dotfiles from Repository

```bash
# Pull latest changes and apply
chezmoi update

# Or manually
chezmoi git pull
chezmoi apply
```

### View Changes Before Applying

```bash
# See what would change
chezmoi diff

# See which files would be modified
chezmoi status
```

### Force Re-run Setup Scripts

```bash
# Remove state file to re-run all run_once scripts
rm ~/.local/share/chezmoi/.chezmoistate.boltdb
chezmoi apply
```

## Syncing to GitHub

### Initial Setup

```bash
# Navigate to chezmoi source directory
chezmoi cd

# Create a new repository on GitHub, then:
git remote add origin git@github.com:<your-github-username>/dotfiles.git
git branch -M main
git push -u origin main
```

### Pushing Changes

```bash
# Navigate to chezmoi directory
chezmoi cd

# Stage and commit changes
git add .
git commit -m "Description of changes"
git push
```

## Personal Profile System

This dotfiles repository is **completely generic and shareable**. Your personal information (name, email, GitHub username) and encrypted SSH keys are stored in a **separate private git submodule**.

### Architecture

**Three-Layer Security (Defense in Depth):**

1. **Public Main Repo** (`<your-username>/dotfiles`)
   - Contains all your dotfiles configuration
   - No personal information hardcoded
   - Safe to share and fork

2. **Private Submodule** (`<your-username>/dotfiles-personal`)
   - Contains `data.yaml` with your personal info
   - Contains SSH keys encrypted with age
   - Private repository, linked as git submodule

3. **Age Key** (offline storage)
   - Never committed to git
   - Stored in password manager or secure backup
   - Required to decrypt SSH keys on new machines

**Why this approach?** Even if someone gains access to your private submodule repository, the SSH keys remain encrypted and useless without your age key.

### Creating Your Personal Profile

After your first `chezmoi apply`, create your personal profile:

```bash
# Navigate to chezmoi directory
chezmoi cd

# Run the setup wizard
.scripts/create-personal-profile.sh
```

The script will:
1. Prompt for your GitHub username, name, and email
2. Display your age encryption key — **BACKUP THIS KEY NOW!**
3. Encrypt your SSH keys with age
4. Create a private GitHub repository
5. Link it as a submodule to your main dotfiles
6. Optionally create your public dotfiles repository
7. Push everything to GitHub automatically

**IMPORTANT:** Save your age encryption key to a password manager (1Password, Bitwarden, etc.) immediately when prompted. You'll need it to decrypt SSH keys on new machines.

### Adding SSH Key to GitHub

```bash
# Show your public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
```

### Using on New Machines

**Option 1: With Existing Personal Profile**

```bash
# Install and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>/dotfiles

# At this point, SSH keys are NOT yet decrypted
# Manually restore your age encryption key
mkdir -p ~/.config/chezmoi
nano ~/.config/chezmoi/key.txt  # Paste your backed-up age key
chmod 600 ~/.config/chezmoi/key.txt

# Re-apply to decrypt SSH keys
chezmoi init --force
chezmoi apply
```

**Option 2: Without Personal Profile (Generic Setup)**

If you don't have a personal profile submodule, the dotfiles will prompt you for:
- Full name
- Email address
- GitHub username

These values are stored locally in `~/.config/chezmoi/chezmoi.toml` and used to template configuration files. You can create a personal profile later with the setup script.

### Updating Personal Information

```bash
# Navigate to personal profile
cd ~/.local/share/chezmoi/.personal

# Edit your information
nano data.yaml

# Commit and push changes
git add data.yaml
git commit -m "Update personal information"
git push
```

### What Gets Stored Where?

**Main Dotfiles Repository (Public):**
- ZSH configuration and plugins
- Aliases and functions
- Brewfile and setup scripts
- Font configurations
- Templates that use `{{ .name }}`, `{{ .email }}`, etc.

**Personal Submodule (Private):**
- `data.yaml` — Your name, email, GitHub username
- `private_dot_ssh/encrypted_private_id_ed25519.age` — Encrypted SSH private key
- `private_dot_ssh/id_ed25519.pub` — SSH public key (not encrypted)
- `.gitignore` — Prevents age key from being committed

**Never Committed (Offline):**
- Age encryption key (`~/.config/chezmoi/key.txt`)
- Must be backed up separately in secure location

## Bitwarden Integration

Bitwarden is included for password and secrets management, including secure storage of your age encryption key.

### Setup

```bash
# Login to Bitwarden
bw login

# Unlock your vault (stores session key)
bw-unlock

# Check status
bw-status
```

### Storing Your Age Key in Bitwarden

**Recommended:** Store your age encryption key as a secure note in Bitwarden:

1. Open Bitwarden app or use CLI:
   ```bash
   bw-unlock
   cat ~/.config/chezmoi/key.txt | pbcopy  # Copy key to clipboard
   ```

2. Create a secure note:
   - **Name:** "Dotfiles Age Encryption Key"
   - **Content:** Paste your age key
   - **Folder:** Create a "System Keys" folder (optional)

3. On new machines, retrieve the key:
   ```bash
   # Login and unlock Bitwarden
   bw login
   bw-unlock

   # List secure notes to find the ID
   bw list items --search "Age Encryption Key"

   # Get the key (replace <item-id> with actual ID)
   bw get notes <item-id> > ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```

### Useful Bitwarden Aliases

- `bw-unlock` - Unlock vault and store session
- `bw-lock` - Lock vault and clear session
- `bw-status` - Show vault status (formatted JSON)
- `bw-sync` - Sync vault with server
- `bw-get` - Get an item from vault

### Example: Retrieving Secrets

```bash
# Unlock vault
bw-unlock

# Get password for a login
bw get password github.com

# Get username
bw get username github.com

# Search for items
bw list items --search "ssh"

# Get item details as JSON
bw get item <item-name-or-id> | jq
```

## Maintenance

### Keep Brewfile Updated

Regularly update your Brewfile after installing new packages:

```bash
cd ~/.local/share/chezmoi
brew bundle dump --file=dot_Brewfile --force
git add dot_Brewfile
git commit -m "Update Brewfile"
git push
```

### Update Plugins

```bash
# Update antidote plugins
antidote update

# Update oh-my-posh
brew upgrade oh-my-posh
```

## Troubleshooting

### Fonts Not Rendering

1. Verify font is installed:
   ```bash
   ls ~/Library/Fonts/*Monaco*
   ```

2. Restart iTerm2 completely (Cmd+Q, then reopen)

3. Manually configure if needed:
   - iTerm2 → Preferences → Profiles → Text → Font
   - Select "MonacoNerdFontMono-Regular"

### Plugins Not Loading

```bash
# Reload ZSH configuration
source ~/.zshrc

# Check which plugins are loaded
antidote list

# Reinstall plugins
rm -rf ~/.cache/antidote
source ~/.zshrc
```

### Chezmoi Script Issues

```bash
# View script output
chezmoi apply -v

# Force re-run scripts
rm ~/.local/share/chezmoi/.chezmoistate.boltdb
chezmoi apply -v
```

### Homebrew Issues

```bash
# Update Homebrew
brew update

# Check Brewfile is valid
brew bundle check --file=~/.Brewfile

# Install missing packages
brew bundle install --file=~/.Brewfile
```

## Uninstalling

To remove these dotfiles:

```bash
# Remove managed files (CAREFUL - backs them up first)
chezmoi purge

# Or just uninitialize (keeps files, removes chezmoi management)
rm -rf ~/.local/share/chezmoi
```

## License

Feel free to use and modify as needed.

## Credits

- [chezmoi](https://www.chezmoi.io/) - Dotfile manager
- [oh-my-posh](https://ohmyposh.dev/) - Prompt theme engine
- [Nerd Fonts](https://www.nerdfonts.com/) - Patched fonts with icons
- [antidote](https://getantidote.github.io/) - ZSH plugin manager
- [atuin](https://atuin.sh/) - Shell history tool
