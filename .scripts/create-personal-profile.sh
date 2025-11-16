#!/bin/bash

# Create Personal Profile Script
# Sets up a private submodule with your personal data and encrypted SSH keys

set -e

echo "Personal Profile Setup"
echo "======================"
echo ""

# Get user information
read -p "GitHub username: " GITHUB_USER
read -p "Full name: " FULL_NAME
read -p "Email address: " EMAIL
read -p "Private repo name [dotfiles-personal]: " REPO_NAME
REPO_NAME=${REPO_NAME:-dotfiles-personal}

echo ""
echo "Configuration:"
echo "  GitHub: $GITHUB_USER"
echo "  Name: $FULL_NAME"
echo "  Email: $EMAIL"
echo "  Repo: git@github.com:$GITHUB_USER/$REPO_NAME.git"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

CHEZMOI_SOURCE="$HOME/.local/share/chezmoi"
PERSONAL_DIR="$CHEZMOI_SOURCE/.personal"

# Create personal directory structure
echo ""
echo "Creating personal profile directory..."
mkdir -p "$PERSONAL_DIR/private_dot_ssh"

# Create data.yaml
cat > "$PERSONAL_DIR/data.yaml" <<EOF
name: "$FULL_NAME"
email: "$EMAIL"
github: "$GITHUB_USER"
EOF
echo "✓ Created data.yaml"

# Display age key for backup (DO NOT COMMIT IT)
if [ -f "$HOME/.config/chezmoi/key.txt" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "IMPORTANT: Backup your age encryption key!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$HOME/.config/chezmoi/key.txt"
    echo ""
    echo "Save this key in a secure location:"
    echo "  • Password manager (1Password, Bitwarden, etc.)"
    echo "  • Encrypted note"
    echo "  • Secure physical backup"
    echo ""
    echo "DO NOT commit this key to git!"
    echo "You'll need it to decrypt SSH keys on new machines."
    echo ""
    read -p "Press enter after you've backed up the key..."
else
    echo "⚠ No age key found at ~/.config/chezmoi/key.txt"
    echo "  Generate one with: age-keygen -o ~/.config/chezmoi/key.txt"
fi

# Copy and encrypt SSH keys if they exist
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "✓ Found SSH keys, encrypting them..."

    # Extract the age public key from the key file
    AGE_RECIPIENT=$(grep "public key:" "$HOME/.config/chezmoi/key.txt" | cut -d: -f2 | tr -d ' ')

    # Encrypt the private key using age
    age --encrypt --recipient "$AGE_RECIPIENT" \
        -o "$PERSONAL_DIR/private_dot_ssh/encrypted_private_id_ed25519.age" \
        "$HOME/.ssh/id_ed25519"

    # Copy the public key (no encryption needed)
    cp ~/.ssh/id_ed25519.pub "$PERSONAL_DIR/private_dot_ssh/"

    echo "✓ SSH keys encrypted and saved"
else
    echo "⚠ No SSH keys found at ~/.ssh/id_ed25519"
    echo "  SSH keys will be generated on first setup"
fi

# Create .chezmoiignore
cat > "$PERSONAL_DIR/.chezmoiignore" <<EOF
README.md
age-key.txt
data.yaml
.git
.gitignore
EOF
echo "✓ Created .chezmoiignore"

# Create .gitignore to prevent committing the age key
cat > "$PERSONAL_DIR/.gitignore" <<EOF
# NEVER commit the age encryption key!
age-key.txt
*.key
*.pem

# macOS
.DS_Store
EOF
echo "✓ Created .gitignore (age key will never be committed)"

# Create README
cat > "$PERSONAL_DIR/README.md" <<EOF
# Personal Profile for $FULL_NAME

Private dotfiles profile (submodule).

## Contents

- \`data.yaml\` - Personal information (name, email, github username)
- \`private_dot_ssh/\` - Encrypted SSH keys
- \`.gitignore\` - Prevents age key from being committed

## Security Model

**Age Encryption Key:**
- The age key is **NOT stored in this repository**
- You must backup the age key separately (password manager, encrypted note, etc.)
- On new machines, manually restore the age key to \`~/.config/chezmoi/key.txt\`
- This provides defense in depth: even if this repo is compromised, SSH keys remain encrypted

**SSH Keys:**
- Encrypted with age before committing
- Can only be decrypted with your age key
- Automatically decrypted by chezmoi on new machines (if age key is present)

## Syncing

This is a submodule of your main dotfiles repository.

To update:
\`\`\`bash
cd ~/.local/share/chezmoi/.personal
git add .
git commit -m "Update personal profile"
git push
\`\`\`

## Repository Security

- Must remain **private** on GitHub
- Enable branch protection
- Use 2FA on your GitHub account
- Regularly review repository access
EOF
echo "✓ Created README"

# Initialize git repo
cd "$PERSONAL_DIR"
git init -b main

# Configure git identity for this repo
git config user.name "$FULL_NAME"
git config user.email "$EMAIL"

git add .
git commit -m "Initial personal profile for $FULL_NAME"

# Create GitHub repo and push
echo ""
echo "Creating GitHub repository..."
if command -v gh &> /dev/null; then
    # Check which GitHub account is authenticated
    GH_AUTHENTICATED_USER=$(gh api user --jq .login 2>/dev/null || echo "")

    if [ -n "$GH_AUTHENTICATED_USER" ] && [ "$GH_AUTHENTICATED_USER" != "$GITHUB_USER" ]; then
        echo ""
        echo "⚠ GitHub CLI is authenticated as '$GH_AUTHENTICATED_USER'"
        echo "  but you entered '$GITHUB_USER' as your GitHub username."
        echo ""
        echo "The repository will be created under: $GH_AUTHENTICATED_USER/$REPO_NAME"
        echo ""
        read -p "Continue? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo "Please authenticate with the correct account:"
            echo "  gh auth login"
            echo ""
            echo "Then re-run this script."
            exit 1
        fi
        # Update GITHUB_USER to match authenticated account
        GITHUB_USER="$GH_AUTHENTICATED_USER"
    fi

    gh repo create "$REPO_NAME" --private --source=. --push
    echo "✓ GitHub repository created and pushed"
else
    echo "GitHub CLI not authenticated. Creating repo manually..."
    git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"
    git branch -M main

    echo ""
    echo "⚠ Please create the private repository manually:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Name: $REPO_NAME"
    echo "  3. Make it PRIVATE"
    echo "  4. Don't initialize with README"
    echo ""
    read -p "Press enter when repository is created..."

    git push -u origin main
    echo "✓ Pushed to GitHub"
fi

# Add as submodule to main dotfiles
cd "$CHEZMOI_SOURCE"
if [ ! -f ".gitmodules" ] || ! grep -q ".personal" ".gitmodules"; then
    git submodule add "git@github.com:$GITHUB_USER/$REPO_NAME.git" .personal
    echo "✓ Added as submodule to dotfiles"
else
    echo "✓ Submodule already configured"
fi

# Setup main dotfiles repository on GitHub
echo ""
echo "Setting up main dotfiles repository..."

# Check if main repo has a remote
if ! git remote get-url origin &>/dev/null; then
    echo "No remote found for main dotfiles repository."
    echo ""
    read -p "Create GitHub repository for main dotfiles? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DOTFILES_REPO="dotfiles"
        read -p "Repository name [dotfiles]: " CUSTOM_REPO_NAME
        DOTFILES_REPO=${CUSTOM_REPO_NAME:-dotfiles}

        echo ""
        echo "Creating public repository: $GITHUB_USER/$DOTFILES_REPO"

        if command -v gh &> /dev/null; then
            gh repo create "$DOTFILES_REPO" --public --source=. --remote=origin --description="Personal dotfiles managed with chezmoi"
            echo "✓ Main dotfiles repository created"
        else
            echo ""
            echo "⚠ Please create the public repository manually:"
            echo "  1. Go to https://github.com/new"
            echo "  2. Name: $DOTFILES_REPO"
            echo "  3. Make it PUBLIC"
            echo "  4. Don't initialize with README"
            echo ""
            read -p "Press enter when repository is created..."

            git remote add origin "git@github.com:$GITHUB_USER/$DOTFILES_REPO.git"
            git branch -M main
        fi
    fi
fi

# Commit and push the submodule
echo ""
echo "Committing personal profile submodule..."
git add .gitmodules .personal

# Check if dot_gitignore exists and add it
if [ -f "dot_gitignore" ]; then
    git add dot_gitignore
fi

git commit -m "Add personal profile submodule"
echo "✓ Submodule committed"

# Push to GitHub if remote is configured
if git remote get-url origin &>/dev/null; then
    echo ""
    echo "Pushing to GitHub..."
    git push -u origin main
    echo "✓ Pushed to GitHub"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Personal profile setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your personal profile is at:"
echo "  $PERSONAL_DIR"
echo ""
echo "Repositories:"
echo "  Personal: git@github.com:$GITHUB_USER/$REPO_NAME.git (private)"
if git remote get-url origin &>/dev/null; then
    DOTFILES_URL=$(git remote get-url origin)
    echo "  Dotfiles: $DOTFILES_URL (public)"
fi
echo ""
echo "On new machines, run:"
echo "  sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply $GITHUB_USER/dotfiles"
echo ""
