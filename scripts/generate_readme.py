#!/usr/bin/env python3

import json
import os


def update_packages(ubuntu_version: str):
    with open(f"images/ubuntu/{ubuntu_version}/README.md") as f:
        readme = f.read()

    section_start = "## Installed Packages"
    readme = readme.split(section_start)[0]
    readme += section_start + "\n"

    with open(f"images/ubuntu/{ubuntu_version}/packages.json") as f:
        packages = json.load(f)

    for group in packages:
        title = group["title"]
        items = group["items"]
        readme += f"\n### {title}\n\n"
        for item in items:
            text = item["name"]
            if "version" in item:
                version = item["version"].replace("~", "\\~")
                text += f" {version}"
            if "extra" in item:
                text += f" ({item['extra']})"
            readme += f"- {text}\n"

    with open(f"images/ubuntu/{ubuntu_version}/README.md", "w") as f:
        f.write(readme)


if __name__ == "__main__":
    cwd = os.getcwd()
    if cwd.endswith("scripts"):
        os.chdir("..")

    for version in ["22.04", "24.04"]:
        update_packages(version)
