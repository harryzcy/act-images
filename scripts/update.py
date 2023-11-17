#!/usr/bin/env python3

import json
from urllib.request import urlopen


def get_packages():
    with open("packages.json") as f:
        packages = json.load(f)
    return packages


def get_current_version(packages: dict, language: str):
    for group in packages:
        for item in group["items"]:
            if item["name"] == language:
                return item["version"]
    print(f"Could not find {language} in packages.json")
    return None


def check_go(packages: dict):
    url = "https://golang.org/VERSION?m=text"
    with urlopen(url) as f:
        latest = f.read().decode("utf-8").strip()
    latest = latest.split("\n")[0]
    latest = latest.removeprefix("go")
    current = get_current_version(packages, "Go")
    return current != latest, current, latest


def check_node(packages: dict):
    url = "https://nodejs.org/download/release/index.json"
    with urlopen(url) as f:
        releases = json.loads(f.read().decode("utf-8").strip())

    for release in releases:
        if release["lts"]:
            latest = release["version"]
            break
    latest = latest.removeprefix("v")
    current = get_current_version(packages, "Node")
    return current != latest, current, latest


def check_python(packages: dict):
    url = "https://endoflife.date/api/python.json"
    with urlopen(url) as f:
        releases = json.loads(f.read().decode("utf-8").strip())
    latest = releases[0]["latest"]
    current = get_current_version(packages, "Python")
    return current != latest, current, latest


def check_git(packages: dict):
    url = "https://api.github.com/repos/git/git/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name = tag["name"]
        if "-rc" not in name:
            latest = name
            break
    latest = latest.removeprefix("v")
    current = get_current_version(packages, "git")
    return current != latest, current, latest


def check_jq(packages: dict):
    url = "https://api.github.com/repos/jqlang/jq/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name = tag["name"]
        if "rc" not in name:
            latest = name
            break
    latest = latest.removeprefix("jq-")
    current = get_current_version(packages, "jq")
    return current != latest, current, latest


def main():
    packages = get_packages()

    checks = {
        "Go": check_go,
        "Node": check_node,
        "Python": check_python,
        "git": check_git,
        "jq": check_jq,
    }

    num_updates = 0
    for package, check in checks.items():
        update, current, latest = check(packages)
        if update:
            num_updates += 1
            print(f"{package}: {current} -> {latest}")
    if num_updates == 0:
        print("No updates available")


if __name__ == "__main__":
    main()
