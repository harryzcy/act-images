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
        raise Exception("Could not find {} version".format(language))
    current = matches[1]
    return current


def check_go_version(readme: str):
    url = "https://golang.org/VERSION?m=text"
    with urlopen(url) as f:
        latest = f.read().decode("utf-8").strip()
    latest = latest.split("\n")[0]
    latest = latest.removeprefix("go")
    current = get_current_version(readme, "Go")
    return current != latest, current, latest


def check_node_version(readme: str):
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


def check_python_version(readme: str):
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


def main():
    readme = read_readme()

    print(check_go_version(readme))
    print(check_node_version(readme))
    print(check_python_version(readme))
    print(check_git(readme))


if __name__ == "__main__":
    main()
