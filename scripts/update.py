#!/usr/bin/env python3

import json
from urllib.request import urlopen

files = [
    "images/ubuntu/scripts/build.sh",
    "images/ubuntu/scripts/install.sh",
]


def get_packages():
    with open("packages.json") as f:
        packages = json.load(f)
    return packages


def write_packages(packages: dict):
    with open("packages.json", "w") as f:
        json.dump(packages, f, indent=2)
        f.write("\n")


def update_environment(package: str, from_version: str, to_version: str):
    package_env = f"${package.upper().replace('-', '_')}_VERSION"
    old_env = f'{package_env}="{from_version}"'
    new_env = f'{package_env}="{to_version}"'
    for file in files:
        with open(file) as f:
            contents = f.read()
        new_content = contents.replace(old_env, new_env)
        if new_content != contents:
            print(f"Updating {file}")
            with open(file, "w") as f:
                f.write(new_content)
        else:
            print(f"Skipping {file}")


def update_current(packages: dict, package: str, version: str):
    for group in packages:
        for item in group["items"]:
            if item["name"] == package:
                if item["version"] == version:
                    return False
                update_environment(package, item["version"], version)
                item["version"] = version
                return True
    return None


def update_go(packages: dict):
    url = "https://golang.org/VERSION?m=text"
    with urlopen(url) as f:
        latest = f.read().decode("utf-8").strip()
    latest = latest.split("\n")[0]
    latest = latest.removeprefix("go")
    return update_current(packages, "Go", latest)


def update_node(packages: dict):
    url = "https://nodejs.org/download/release/index.json"
    with urlopen(url) as f:
        releases = json.loads(f.read().decode("utf-8").strip())

    for release in releases:
        if release["lts"]:
            latest = release["version"]
            break
    latest = latest.removeprefix("v")
    return update_current(packages, "Node", latest)


def update_python(packages: dict):
    url = "https://endoflife.date/api/python.json"
    with urlopen(url) as f:
        releases = json.loads(f.read().decode("utf-8").strip())
    latest = releases[0]["latest"]
    return update_current(packages, "Python", latest)


def update_git(packages: dict):
    url = "https://api.github.com/repos/git/git/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name = tag["name"]
        if "-rc" not in name:
            latest = name
            break
    latest = latest.removeprefix("v")
    return update_current(packages, "git", latest)


def update_jq(packages: dict):
    url = "https://api.github.com/repos/jqlang/jq/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name = tag["name"]
        if "rc" not in name:
            latest = name
            break
    latest = latest.removeprefix("jq-")
    return update_current(packages, "jq", latest)


def main():
    packages = get_packages()

    checks = {
        "Go": update_go,
        "Node": update_node,
        "Python": update_python,
        "git": update_git,
        "jq": update_jq,
    }

    num_updates = 0
    for _, check in checks.items():
        updated = check(packages)
        if updated:
            num_updates += 1
    if num_updates == 0:
        print("No updates available")
    else:
        write_packages(packages)
        print(f"Updated {num_updates} packages")


if __name__ == "__main__":
    main()
