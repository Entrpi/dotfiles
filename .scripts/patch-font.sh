#!/bin/bash

# Font Patcher Script
# Patches any font with Nerd Font glyphs
#
# Usage: ./patch-font.sh /path/to/font.ttf

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <font-file>"
    echo ""
    echo "Example:"
    echo "  $0 /System/Library/Fonts/Monaco.ttf"
    echo "  $0 ~/Downloads/MyFont.ttf"
    exit 1
fi

FONT_FILE="$1"

if [ ! -f "$FONT_FILE" ]; then
    echo "Error: Font file not found: $FONT_FILE"
    exit 1
fi

echo "Font Patcher for Nerd Fonts"
echo "=============================="
echo ""
echo "Font to patch: $FONT_FILE"
echo ""

# Check if fontforge is installed
if ! command -v fontforge &> /dev/null; then
    echo "Installing fontforge..."
    brew install fontforge
fi

# Clone/update nerd-fonts repo if needed
NERD_FONTS_DIR=~/nerd-fonts

if [ ! -d "$NERD_FONTS_DIR" ]; then
    echo "Cloning nerd-fonts repository..."
    cd ~
    git clone --filter=blob:none --depth=1 --sparse https://github.com/ryanoasis/nerd-fonts.git
    cd "$NERD_FONTS_DIR"
    git sparse-checkout set bin/scripts src/glyphs
    git sparse-checkout add font-patcher
    git checkout
else
    echo "Using existing nerd-fonts repository at $NERD_FONTS_DIR"
fi

# Patch the font
echo ""
echo "Patching font..."
cd "$NERD_FONTS_DIR"

./font-patcher --mono --complete --outputdir ~/Library/Fonts "$FONT_FILE"

echo ""
echo "✓ Font patched successfully!"
echo "  Output location: ~/Library/Fonts/"
echo ""
echo "To configure iTerm2 to use the patched font:"
echo "  1. Open iTerm2 Preferences (Cmd+,)"
echo "  2. Go to Profiles > Text"
echo "  3. Click on Font and select your patched font"
echo "  4. Look for fonts with 'Nerd Font' in the name"
