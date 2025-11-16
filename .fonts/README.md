# Nerd Fonts

This directory contains patched fonts with Nerd Font glyphs.

## Included Fonts

- **MonacoNerdFontMono-Regular.ttf** - Monaco font patched with Nerd Font icons
  - Size: ~2.5MB
  - Includes: Seti-UI, Devicons, Font Awesome, Font Logos, Octicons, Codicons, and more
  - Perfect for terminal use with oh-my-posh and other powerline themes

## Automatic Installation

The font is automatically installed when you run `chezmoi apply` via the
`run_once_before_10-install-nerd-fonts.sh.tmpl` script.

## Manual Font Patching

To patch additional fonts, use the included script:

```bash
chezmoi cd
.scripts/patch-font.sh /path/to/your/font.ttf
```

## iTerm2 Configuration

The installation script automatically configures iTerm2 to use Monaco Nerd Font.
After running chezmoi apply, restart iTerm2 to see the changes.

You can also configure manually:
1. Open iTerm2 Preferences (Cmd+,)
2. Go to Profiles > Text > Font
3. Select "MonacoNerdFontMono-Regular"
