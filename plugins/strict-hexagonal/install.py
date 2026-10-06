#!/usr/bin/env python3
"""Voidlight Skill Library Installer
Python 3 fallback - cross-platform (Linux, macOS, Windows)

Usage:
    python install.py [OPTIONS] [SKILL]
    python -c "$(curl -sL ...)" python-craft

Examples:
    python install.py python-craft
    python install.py --all
    python install.py --agent gemini python-craft
"""

import argparse
import os
import platform
import shutil
import sys
import tempfile
import urllib.request
from pathlib import Path

REPO_OWNER = "voidlight-labs"
REPO_NAME = "voidlight-plugin-library"
BRANCH = "main"
PLUGIN_DIR = "plugins/strict-hexagonal"
RAW_BASE = f"https://raw.githubusercontent.com/{REPO_OWNER}/{REPO_NAME}/{BRANCH}"

SKILLS = [
    "java-craft",
    "python-craft",
    "rust-craft",
    "typescript-craft",
    "nuxt-craft",
    "nextjs-craft",
    "prd-craft",
    "craft-router",
]

# Agent paths
HOME = Path.home()
OPENCODE_DIR = HOME / ".agents" / "skills"
KIMI_DIR = HOME / ".kimi-code" / "skills"
GEMINI_FILE = HOME / ".gemini" / "GEMINI.md"


def print_info(msg: str) -> None:
    print(f"[INFO] {msg}")


def print_success(msg: str) -> None:
    print(f"[OK] {msg}")


def print_warn(msg: str) -> None:
    print(f"[WARN] {msg}")


def print_error(msg: str) -> None:
    print(f"[ERROR] {msg}", file=sys.stderr)


def detect_agent(args_agent: str | None = None) -> str:
    """Detect which agent environment we're in."""
    if args_agent:
        return args_agent

    # Check for OpenCode
    if OPENCODE_DIR.exists():
        return "opencode"

    # Check for Kimi
    if KIMI_DIR.exists() or shutil.which("kimi"):
        return "kimi"

    # Check for Gemini
    if GEMINI_FILE.parent.exists() or shutil.which("gemini"):
        return "gemini"

    # Check for Claude project
    if Path("CLAUDE.md").exists() or Path(".claude").exists():
        return "claude"

    # Check for Codex/Copilot
    if Path(".github/copilot-instructions.md").exists() or Path(".github").exists():
        return "codex"

    # Default to paste mode
    return "paste"


def get_skill_url(skill_name: str) -> str:
    return f"{RAW_BASE}/{PLUGIN_DIR}/skills/{skill_name}/SKILL.md"


def download_skill(skill_name: str) -> Path:
    """Download skill from GitHub raw."""
    url = get_skill_url(skill_name)
    tmpfile = Path(tempfile.mktemp(suffix=".md"))

    try:
        urllib.request.urlretrieve(url, tmpfile)
    except Exception as e:
        print_error(f"Failed to download {skill_name}: {e}")
        sys.exit(1)

    if not tmpfile.exists() or tmpfile.stat().st_size == 0:
        print_error(f"Downloaded file is empty. Please check the skill name: {skill_name}")
        sys.exit(1)

    return tmpfile


def prompt_overwrite(target: Path, force: bool = False) -> bool:
    """Ask user before overwriting existing file."""
    if target.exists() and not force:
        reply = input(f"{target} already exists. Overwrite? [y/N] ")
        return reply.lower().startswith("y")
    return True


def install_opencode(skill_name: str, tmpfile: Path, force: bool = False) -> None:
    target_dir = OPENCODE_DIR / skill_name
    target_file = target_dir / "SKILL.md"
    target_dir.mkdir(parents=True, exist_ok=True)

    if prompt_overwrite(target_file, force):
        shutil.copy2(tmpfile, target_file)
        print_success(f"Installed {skill_name} to {target_file}")
    else:
        print_info(f"Skipped {skill_name}")


def install_kimi(skill_name: str, tmpfile: Path, force: bool = False) -> None:
    target_dir = KIMI_DIR / skill_name
    target_file = target_dir / "SKILL.md"
    target_dir.mkdir(parents=True, exist_ok=True)

    if prompt_overwrite(target_file, force):
        shutil.copy2(tmpfile, target_file)
        print_success(f"Installed {skill_name} to {target_file}")
    else:
        print_info(f"Skipped {skill_name}")


def install_gemini(skill_name: str, tmpfile: Path, force: bool = False) -> None:
    GEMINI_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(GEMINI_FILE, "a", encoding="utf-8") as f:
        f.write("\n\n")
        f.write(f"<!-- Voidlight Skill: {skill_name} -->\n")
        f.write(f"<!-- Source: https://github.com/{REPO_OWNER}/{REPO_NAME} -->\n")
        f.write("<!-- Version: 3.0.0 -->\n")
        f.write("\n")
        f.write(tmpfile.read_text(encoding="utf-8"))

    print_success(f"Appended {skill_name} to {GEMINI_FILE}")


def install_claude(skill_name: str, tmpfile: Path, force: bool = False) -> None:
    target_file = Path("CLAUDE.md")

    if prompt_overwrite(target_file, force):
        content = tmpfile.read_text(encoding="utf-8")
        with open(target_file, "w", encoding="utf-8") as f:
            f.write(f"# Voidlight Skill: {skill_name}\n\n")
            f.write(f"This file contains coding standards and architecture rules for {skill_name}.\n\n")
            f.write(content)
        print_success(f"Created {target_file} for {skill_name}")
    else:
        print_info(f"Skipped {skill_name}")


def install_codex(skill_name: str, tmpfile: Path, force: bool = False) -> None:
    target_dir = Path(".github")
    target_file = target_dir / "copilot-instructions.md"
    target_dir.mkdir(parents=True, exist_ok=True)

    if prompt_overwrite(target_file, force):
        content = tmpfile.read_text(encoding="utf-8")
        with open(target_file, "w", encoding="utf-8") as f:
            f.write(f"# GitHub Copilot Instructions: {skill_name}\n\n")
            f.write(f"<!-- Generated from Voidlight Skill Library -->\n")
            f.write(f"<!-- https://github.com/{REPO_OWNER}/{REPO_NAME} -->\n\n")
            f.write(content)
        print_success(f"Created {target_file} for {skill_name}")
    else:
        print_info(f"Skipped {skill_name}")


def install_paste(skill_name: str, tmpfile: Path) -> None:
    print_info(f"Outputting {skill_name} for copy-paste...")
    print(f"\n=== VOIDLIGHT SKILL: {skill_name} ===\n")
    print(tmpfile.read_text(encoding="utf-8"))
    print(f"\n=== END OF {skill_name} ===\n")


def install_single(skill_name: str, agent: str | None = None, force: bool = False) -> None:
    detected = detect_agent(agent)
    print_info(f"Installing {skill_name} for {detected}...")
    tmpfile = download_skill(skill_name)

    try:
        if detected == "opencode":
            install_opencode(skill_name, tmpfile, force)
        elif detected == "kimi":
            install_kimi(skill_name, tmpfile, force)
        elif detected == "gemini":
            install_gemini(skill_name, tmpfile, force)
        elif detected == "claude":
            install_claude(skill_name, tmpfile, force)
        elif detected == "codex":
            install_codex(skill_name, tmpfile, force)
        elif detected == "paste":
            install_paste(skill_name, tmpfile)
        else:
            print_error(f"Unknown agent: {detected}")
            sys.exit(1)
    finally:
        tmpfile.unlink(missing_ok=True)


def install_all(agent: str | None = None, force: bool = False) -> None:
    detected = detect_agent(agent)
    print_info(f"Installing all skills for {detected}...")
    for skill in SKILLS:
        install_single(skill, detected, force)
    print_success("All skills installed!")


def list_installed() -> None:
    print_info("Installed Voidlight skills:")

    if OPENCODE_DIR.exists():
        print(f"\nOpenCode ({OPENCODE_DIR}):")
        for item in sorted(OPENCODE_DIR.iterdir()):
            if item.is_dir():
                print(f"  {item.name}")

    if KIMI_DIR.exists():
        print(f"\nKimi ({KIMI_DIR}):")
        for item in sorted(KIMI_DIR.iterdir()):
            if item.is_dir():
                print(f"  {item.name}")

    if GEMINI_FILE.exists():
        print(f"\nGemini ({GEMINI_FILE}):")
        content = GEMINI_FILE.read_text(encoding="utf-8")
        for line in content.splitlines():
            if "Voidlight Skill:" in line:
                skill = line.split("Voidlight Skill:")[1].strip().replace("-->", "").strip()
                print(f"  {skill}")

    if Path("CLAUDE.md").exists():
        print(f"\nClaude (CLAUDE.md):")
        with open("CLAUDE.md", encoding="utf-8") as f:
            first_line = f.readline().strip()
            print(f"  {first_line}")

    if Path(".github/copilot-instructions.md").exists():
        print(f"\nCodex (.github/copilot-instructions.md):")
        with open(".github/copilot-instructions.md", encoding="utf-8") as f:
            first_line = f.readline().strip()
            print(f"  {first_line}")


def remove_skill(skill_name: str) -> None:
    removed = False

    # OpenCode
    target = OPENCODE_DIR / skill_name
    if target.exists():
        shutil.rmtree(target)
        print_success(f"Removed {skill_name} from OpenCode")
        removed = True

    # Kimi
    target = KIMI_DIR / skill_name
    if target.exists():
        shutil.rmtree(target)
        print_success(f"Removed {skill_name} from Kimi")
        removed = True

    # Gemini
    if GEMINI_FILE.exists():
        content = GEMINI_FILE.read_text(encoding="utf-8")
        if f"Voidlight Skill: {skill_name}" in content:
            lines = content.splitlines()
            new_lines = []
            skip = False
            for line in lines:
                if f"<!-- Voidlight Skill: {skill_name} -->" in line:
                    skip = True
                    continue
                if skip and line.startswith("<!-- Voidlight Skill:"):
                    skip = False
                if not skip:
                    new_lines.append(line)
            GEMINI_FILE.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
            print_success(f"Removed {skill_name} from Gemini")
            removed = True

    if not removed:
        print_warn(f"{skill_name} not found in any agent")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Voidlight Skill Library Installer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python install.py python-craft
  python install.py --all
  python install.py --agent gemini python-craft
  python install.py --list
  python install.py --remove python-craft

Supported skills:
  java-craft, python-craft, rust-craft,
  typescript-craft, nuxt-craft, nextjs-craft

Agent targets:
  opencode   -> ~/.agents/skills/{skill}/SKILL.md
  kimi       -> ~/.kimi-code/skills/{skill}/SKILL.md
  gemini     -> ~/.gemini/GEMINI.md (append)
  claude     -> CLAUDE.md (project root)
  codex      -> .github/copilot-instructions.md

Auto-detect order: OpenCode -> Kimi -> Gemini -> Claude -> Codex -> Paste
        """,
    )

    parser.add_argument("skill", nargs="?", help="Skill to install (e.g., python-craft)")
    parser.add_argument("--all", action="store_true", help="Install all skills")
    parser.add_argument("--update", action="store_true", help="Update a specific skill")
    parser.add_argument("--list", action="store_true", help="List installed skills")
    parser.add_argument("--remove", action="store_true", help="Remove a specific skill")
    parser.add_argument("--agent", help="Force specific agent (opencode, kimi, gemini, claude, codex)")
    parser.add_argument("--force", action="store_true", help="Overwrite without prompting")

    args = parser.parse_args()

    if args.list:
        list_installed()
        return

    if args.all:
        install_all(args.agent, args.force)
        return

    if args.remove:
        if not args.skill:
            print_error("Usage: install.py --remove SKILL")
            sys.exit(1)
        remove_skill(args.skill)
        return

    if args.update:
        if not args.skill:
            print_error("Usage: install.py --update SKILL")
            sys.exit(1)
        install_single(args.skill, args.agent, args.force)
        return

    if args.skill:
        install_single(args.skill, args.agent, args.force)
        return

    parser.print_help()


if __name__ == "__main__":
    main()
