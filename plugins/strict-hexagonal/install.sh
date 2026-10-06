#!/usr/bin/env sh
# Voidlight Skill Library Installer
# POSIX-compatible shell script
# Usage: curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-skill-library/main/install.sh | bash -s -- [OPTIONS] [SKILL]

set -e

REPO_OWNER="voidlight-labs"
REPO_NAME="voidlight-plugin-library"
PLUGIN_DIR="plugins/strict-hexagonal"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

SKILLS="java-craft python-craft rust-craft typescript-craft nuxt-craft nextjs-craft prd-craft craft-router"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Agent paths
OPENCODE_DIR="${HOME}/.agents/skills"
KIMI_DIR="${HOME}/.kimi-code/skills"
GEMINI_FILE="${HOME}/.gemini/GEMINI.md"

# Determine if we support colors
if [ -t 1 ]; then
    COLOR_SUPPORT=1
else
    COLOR_SUPPORT=0
fi

print_info() {
    if [ "$COLOR_SUPPORT" -eq 1 ]; then
        printf "${BLUE}[INFO]${NC} %s\n" "$1"
    else
        printf "[INFO] %s\n" "$1"
    fi
}

print_success() {
    if [ "$COLOR_SUPPORT" -eq 1 ]; then
        printf "${GREEN}[OK]${NC} %s\n" "$1"
    else
        printf "[OK] %s\n" "$1"
    fi
}

print_warn() {
    if [ "$COLOR_SUPPORT" -eq 1 ]; then
        printf "${YELLOW}[WARN]${NC} %s\n" "$1"
    else
        printf "[WARN] %s\n" "$1"
    fi
}

print_error() {
    if [ "$COLOR_SUPPORT" -eq 1 ]; then
        printf "${RED}[ERROR]${NC} %s\n" "$1"
    else
        printf "[ERROR] %s\n" "$1"
    fi
}

detect_agent() {
    if [ -n "$AGENT" ]; then
        echo "$AGENT"
        return
    fi

    # Check for OpenCode
    if [ -d "$OPENCODE_DIR" ]; then
        echo "opencode"
        return
    fi

    # Check for Kimi
    if [ -d "$KIMI_DIR" ] || command -v kimi >/dev/null 2>&1; then
        echo "kimi"
        return
    fi

    # Check for Gemini
    if [ -d "${HOME}/.gemini" ] || command -v gemini >/dev/null 2>&1; then
        echo "gemini"
        return
    fi

    # Check for Claude project
    if [ -f "CLAUDE.md" ] || [ -d ".claude" ]; then
        echo "claude"
        return
    fi

    # Check for Codex/Copilot
    if [ -f ".github/copilot-instructions.md" ] || [ -d ".github" ]; then
        echo "codex"
        return
    fi

    # Default to stdout for paste
    echo "paste"
}

get_skill_url() {
    skill_name="$1"
    echo "${RAW_BASE}/${PLUGIN_DIR}/skills/${skill_name}/SKILL.md"
}

download_skill() {
    skill_name="$1"
    url=$(get_skill_url "$skill_name")
    tmpfile=$(mktemp)

    if command -v curl >/dev/null 2>&1; then
        curl -sL "$url" -o "$tmpfile"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$tmpfile"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    # Check if download succeeded
    if [ ! -s "$tmpfile" ]; then
        rm -f "$tmpfile"
        print_error "Failed to download ${skill_name}. Please check the skill name and try again."
        exit 1
    fi

    echo "$tmpfile"
}

prompt_overwrite() {
    target="$1"
    if [ -e "$target" ] && [ "$FORCE" != "1" ]; then
        printf "%s already exists. Overwrite? [y/N] " "$target"
        read -r reply
        case "$reply" in
            [Yy]* ) return 0 ;;
            * ) return 1 ;;
        esac
    fi
    return 0
}

install_opencode() {
    skill_name="$1"
    tmpfile="$2"
    target_dir="${OPENCODE_DIR}/${skill_name}"
    target_file="${target_dir}/SKILL.md"

    mkdir -p "$target_dir"
    if prompt_overwrite "$target_file"; then
        cp "$tmpfile" "$target_file"
        print_success "Installed ${skill_name} to ${target_file}"
    else
        print_info "Skipped ${skill_name}"
    fi
}

install_kimi() {
    skill_name="$1"
    tmpfile="$2"
    target_dir="${KIMI_DIR}/${skill_name}"
    target_file="${target_dir}/SKILL.md"

    mkdir -p "$target_dir"
    if prompt_overwrite "$target_file"; then
        cp "$tmpfile" "$target_file"
        print_success "Installed ${skill_name} to ${target_file}"
    else
        print_info "Skipped ${skill_name}"
    fi
}

install_gemini() {
    skill_name="$1"
    tmpfile="$2"
    target_file="$GEMINI_FILE"
    target_dir=$(dirname "$target_file")

    mkdir -p "$target_dir"

    # Append with separator
    {
        printf "\n\n"
        printf "<!-- Voidlight Skill: %s -->\n" "$skill_name"
        printf "<!-- Source: https://github.com/%s/%s -->\n" "$REPO_OWNER" "$REPO_NAME"
        printf "<!-- Version: 4.0.0 -->\n"
        printf "\n"
        cat "$tmpfile"
    } >> "$target_file"

    print_success "Appended ${skill_name} to ${target_file}"
}

install_claude() {
    skill_name="$1"
    tmpfile="$2"
    target_file="CLAUDE.md"

    if prompt_overwrite "$target_file"; then
        # Add a header to make it clear
        {
            printf "# Voidlight Skill: %s\n\n" "$skill_name"
            printf "This file contains coding standards and architecture rules for %s.\n\n" "$skill_name"
            cat "$tmpfile"
        } > "$target_file"
        print_success "Created ${target_file} for ${skill_name}"
    else
        print_info "Skipped ${skill_name}"
    fi
}

install_codex() {
    skill_name="$1"
    tmpfile="$2"
    target_dir=".github"
    target_file="${target_dir}/copilot-instructions.md"

    mkdir -p "$target_dir"
    if prompt_overwrite "$target_file"; then
        {
            printf "# GitHub Copilot Instructions: %s\n\n" "$skill_name"
            printf "<!-- Generated from Voidlight Skill Library -->\n"
            printf "<!-- https://github.com/%s/%s -->\n\n" "$REPO_OWNER" "$REPO_NAME"
            cat "$tmpfile"
        } > "$target_file"
        print_success "Created ${target_file} for ${skill_name}"
    else
        print_info "Skipped ${skill_name}"
    fi
}

install_paste() {
    skill_name="$1"
    tmpfile="$2"

    print_info "Outputting ${skill_name} for copy-paste..."
    printf "\n=== VOIDLIGHT SKILL: %s ===\n\n" "$skill_name"
    cat "$tmpfile"
    printf "\n=== END OF %s ===\n\n" "$skill_name"
}

install_single() {
    skill_name="$1"
    agent=$(detect_agent)

    print_info "Installing ${skill_name} for ${agent}..."
    tmpfile=$(download_skill "$skill_name")

    case "$agent" in
        opencode)
            install_opencode "$skill_name" "$tmpfile"
            ;;
        kimi)
            install_kimi "$skill_name" "$tmpfile"
            ;;
        gemini)
            install_gemini "$skill_name" "$tmpfile"
            ;;
        claude)
            install_claude "$skill_name" "$tmpfile"
            ;;
        codex)
            install_codex "$skill_name" "$tmpfile"
            ;;
        paste)
            install_paste "$skill_name" "$tmpfile"
            ;;
        *)
            print_error "Unknown agent: ${agent}"
            rm -f "$tmpfile"
            exit 1
            ;;
    esac

    rm -f "$tmpfile"
}

install_all() {
    agent=$(detect_agent)
    print_info "Installing all skills for ${agent}..."
    for skill in $SKILLS; do
        install_single "$skill"
    done
    print_success "All skills installed!"
}

list_installed() {
    print_info "Installed Voidlight skills:"

    if [ -d "$OPENCODE_DIR" ]; then
        printf "\n${BLUE}OpenCode (${OPENCODE_DIR}):${NC}\n"
        ls -1 "$OPENCODE_DIR" 2>/dev/null || echo "  (none)"
    fi

    if [ -d "$KIMI_DIR" ]; then
        printf "\n${BLUE}Kimi (${KIMI_DIR}):${NC}\n"
        ls -1 "$KIMI_DIR" 2>/dev/null || echo "  (none)"
    fi

    if [ -f "$GEMINI_FILE" ]; then
        printf "\n${BLUE}Gemini (${GEMINI_FILE}):${NC}\n"
        grep -o "Voidlight Skill: [^ ]*" "$GEMINI_FILE" 2>/dev/null | sed 's/Voidlight Skill: /  /' || echo "  (none)"
    fi

    if [ -f "CLAUDE.md" ]; then
        printf "\n${BLUE}Claude (CLAUDE.md):${NC}\n"
        head -1 "CLAUDE.md" 2>/dev/null || echo "  (none)"
    fi

    if [ -f ".github/copilot-instructions.md" ]; then
        printf "\n${BLUE}Codex (.github/copilot-instructions.md):${NC}\n"
        head -1 ".github/copilot-instructions.md" 2>/dev/null || echo "  (none)"
    fi
}

remove_skill() {
    skill_name="$1"
    removed=0

    # OpenCode
    if [ -d "${OPENCODE_DIR}/${skill_name}" ]; then
        rm -rf "${OPENCODE_DIR}/${skill_name}"
        print_success "Removed ${skill_name} from OpenCode"
        removed=1
    fi

    # Kimi
    if [ -d "${KIMI_DIR}/${skill_name}" ]; then
        rm -rf "${KIMI_DIR}/${skill_name}"
        print_success "Removed ${skill_name} from Kimi"
        removed=1
    fi

    # Gemini
    if [ -f "$GEMINI_FILE" ]; then
        if grep -q "Voidlight Skill: ${skill_name}" "$GEMINI_FILE"; then
            # Remove the section (this is a simple approach, may leave blank lines)
            awk -v skill="$skill_name" '
                BEGIN { skip=0 }
                /<!-- Voidlight Skill: / { skip=($0 ~ "<!-- Voidlight Skill: " skill " -->") ? 1 : 0 }
                !skip { print }
                /<!-- END OF VOIDLIGHT SKILL: / { skip=0 }
            ' "$GEMINI_FILE" > "${GEMINI_FILE}.tmp" && mv "${GEMINI_FILE}.tmp" "$GEMINI_FILE"
            print_success "Removed ${skill_name} from Gemini"
            removed=1
        fi
    fi

    if [ "$removed" -eq 0 ]; then
        print_warn "${skill_name} not found in any agent"
    fi
}

show_help() {
    cat <<EOF
Voidlight Skill Library Installer

Usage:
  install.sh [OPTIONS] [SKILL]

Install a specific skill:
  install.sh python-craft

Options:
  --all                  Install all 6 skills
  --update SKILL         Update a specific skill (same as install)
  --list                 List installed Voidlight skills
  --remove SKILL         Remove a specific skill
  --agent AGENT          Force specific agent (opencode, kimi, gemini, claude, codex)
  --force                Overwrite without prompting
  --help                 Show this help message

Supported skills:
  java-craft, python-craft, rust-craft,
  typescript-craft, nuxt-craft, nextjs-craft

Agent targets:
  opencode   -> ~/.agents/skills/{skill}/SKILL.md
  kimi       -> ~/.kimi-code/skills/{skill}/SKILL.md
  gemini     -> ~/.gemini/GEMINI.md (append)
  claude     -> CLAUDE.md (project root)
  codex      -> .github/copilot-instructions.md

Auto-detect order:
  OpenCode -> Kimi -> Gemini -> Claude -> Codex

Examples:
  curl -sL https://raw.githubusercontent.com/voidlight-labs/voidlight-skill-library/main/install.sh | bash -s -- python-craft
  curl -sL ... | bash -s -- --all
  curl -sL ... | bash -s -- --agent gemini python-craft

For safety, you can download and inspect first:
  curl -sL ... > install.sh && cat install.sh && bash install.sh python-craft

EOF
}

# Parse arguments
AGENT=""
FORCE="0"
COMMAND=""
TARGET=""

while [ $# -gt 0 ]; do
    case "$1" in
        --all)
            COMMAND="all"
            ;;
        --update)
            COMMAND="update"
            ;;
        --list)
            COMMAND="list"
            ;;
        --remove)
            COMMAND="remove"
            ;;
        --agent)
            shift
            AGENT="$1"
            ;;
        --force)
            FORCE="1"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
            else
                print_error "Unexpected argument: $1"
                show_help
                exit 1
            fi
            ;;
    esac
    shift
done

# Execute command
case "$COMMAND" in
    all)
        install_all
        ;;
    update)
        if [ -z "$TARGET" ]; then
            print_error "Usage: install.sh --update SKILL"
            exit 1
        fi
        install_single "$TARGET"
        ;;
    list)
        list_installed
        ;;
    remove)
        if [ -z "$TARGET" ]; then
            print_error "Usage: install.sh --remove SKILL"
            exit 1
        fi
        remove_skill "$TARGET"
        ;;
    "")
        if [ -n "$TARGET" ]; then
            install_single "$TARGET"
        else
            show_help
            exit 1
        fi
        ;;
esac
