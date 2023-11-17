#!/usr/bin/env python3

import json
import os


def update_packages():
    with open("README.md") as f:
        readme = f.read()

    section_start = "## Installed Packages"
    readme = readme.split(section_start)[0]
    readme += section_start + "\n"

    with open("packages.json") as f:
        packages = json.load(f)

    for group in packages:
        title = group["title"]
        items = group["items"]
        readme += f"\n### {title}\n\n"
        for item in items:
            text = item["name"]
            if "version" in item:
                text += f" {item['version']}"
            readme += f"- {text}\n"

    with open("README.md", "w") as f:
        f.write(readme)


if __name__ == "__main__":
    cwd = os.getcwd()
    if cwd.endswith("scripts"):
        os.chdir("..")

    update_packages()
