#!/usr/bin/env python3
"""
Generate a REPO_TREE.txt similar to the one bundled in cf-core.
Usage: python3 gen_repo_tree.py /path/to/repo_root > _meta/REPO_TREE.txt
"""
from __future__ import annotations
import os, sys
from pathlib import Path

EXCLUDE_DIRS = {".git", "__pycache__"}
EXCLUDE_FILES = set()

def iter_entries(root: Path):
    for p in sorted(root.iterdir(), key=lambda x: (x.is_file(), x.name.lower())):
        if p.name in EXCLUDE_DIRS:
            continue
        if p.is_file() and p.name in EXCLUDE_FILES:
            continue
        yield p

def render_tree(root: Path) -> str:
    lines = [f"{root.name}/"]
    def walk(dir_path: Path, prefix: str):
        entries = list(iter_entries(dir_path))
        for i, p in enumerate(entries):
            last = (i == len(entries)-1)
            branch = "└─ " if last else "├─ "
            if p.is_dir():
                lines.append(f"{prefix}{branch}{p.name}/")
                walk(p, prefix + ("   " if last else "│  "))
            else:
                lines.append(f"{prefix}{branch}{p.name}")
    walk(root, "")
    return "\n".join(lines) + "\n"

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 gen_repo_tree.py /path/to/repo_root", file=sys.stderr)
        sys.exit(2)
    root = Path(sys.argv[1]).resolve()
    if not root.is_dir():
        raise SystemExit(f"Not a directory: {root}")
    sys.stdout.write(render_tree(root))

if __name__ == "__main__":
    main()
