#!/usr/bin/env python3

from urllib.request import urlopen
import re
import json


def read_readme():
    with open("README.md") as f:
        readme = f.read()
    return readme


def get_current_version(readme: str, language: str):
    pattern = r"{} ([0-9.]+)".format(language)
    matches = re.search(pattern, readme)
    if matches is None:
        print("Could not find {} version in README.md".format(language))
        return None
    current = matches[1]
    return current


def check_go(readme: str):
    url = "https://golang.org/VERSION?m=text"
    with urlopen(url) as f:
        latest = f.read().decode("utf-8").strip()
    latest = latest.split("\n")[0]
    latest = latest.removeprefix("go")
    current = get_current_version(readme, "Go")
    return current != latest, current, latest


def check_node(readme: str):
    url = "https://nodejs.org/download/release/index.json"
    with urlopen(url) as f:
        releases = json.loads(f.read().decode("utf-8").strip())

    for release in releases:
        if release["lts"]:
            latest = release["version"]
            break
    latest = latest.removeprefix("v")
    current = get_current_version(readme, "Node")
    return current != latest, current, latest


def check_python(readme: str):
    url = "https://endoflife.date/api/python.json"
    with urlopen(url) as f:
        releases = json.loads(f.read().decode("utf-8").strip())
    latest = releases[0]["latest"]
    current = get_current_version(readme, "Python")
    return current != latest, current, latest


def check_git(readme: str):
    url = "https://api.github.com/repos/git/git/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name = tag["name"]
        if "-rc" not in name:
            latest = name
            break
    latest = latest.removeprefix("v")
    current = get_current_version(readme, "git")
    return current != latest, current, latest


def check_jq(readme: str):
    url = "https://api.github.com/repos/jqlang/jq/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name = tag["name"]
        if "rc" not in name:
            latest = name
            break
    latest = latest.removeprefix("jq-")
    current = get_current_version(readme, "jq")
    return current != latest, current, latest


def main():
    readme = read_readme()

    checks = {
        "Go": check_go,
        "Node": check_node,
        "Python": check_python,
        "git": check_git,
        "jq": check_jq,
    }

    num_updates = 0
    for package, check in checks.items():
        update, current, latest = check(readme)
        if update:
            num_updates += 1
            print(f"{package}: {current} -> {latest}")
    if num_updates == 0:
        print("No updates available")


if __name__ == "__main__":
    main()
