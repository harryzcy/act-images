#!/usr/bin/env python3

import json
from urllib.request import urlopen

padding = 2
padding_str = " " * padding

script_files = [
    "images/ubuntu/scripts/build.sh",
    "images/ubuntu/scripts/install.sh",
]

requirements_files = [
    "images/ubuntu/scripts/requirements-pip.txt",
    "images/ubuntu/scripts/requirements-pipx.txt",
]


def get_packages():
    with open("packages.json") as f:
        packages = json.load(f)
    return packages


def write_packages(packages: dict):
    with open("packages.json", "w") as f:
        json.dump(packages, f, indent=2)
        f.write("\n")


def update_script_files(package: str, from_version: str, to_version: str):
    package_env = f"{package.upper().replace('-', '_')}_VERSION"
    old_env = f'{package_env}="{from_version}"'
    new_env = f'{package_env}="{to_version}"'
    for file in script_files:
        with open(file) as f:
            contents = f.read()
        new_content = contents.replace(old_env, new_env)
        if new_content == contents:
            print(f"Skipping {file}")
            continue
        print(f"Updating {file}")

        with open(file, "w") as f:
            f.write(new_content)


def update_requirements_files(
    package: str, from_version: str, to_version: str, sha256s: list = None
):
    old = f"{package}=={from_version}"
    new = f"{package}=={to_version}"
    for file in requirements_files:
        with open(file) as f:
            contents = f.read()
        new_content = contents.replace(old, new)
        if new_content == contents:
            print(f"Skipping {file}")
            continue

        if sha256s:
            # Update the sha256s
            lines = new_content.split("\n")
            line_number = 0
            for line in lines:
                if f"{package}==" in line:
                    break
                line_number += 1
            if not line.strip().endswith("\\"):
                lines[line_number] = line.strip() + " \\"
                line_number += 1
            # remove the old sha256s
            while "sha256:" in lines[line_number]:
                lines.pop(line_number)
            # add the new sha256s
            for index, sha256 in enumerate(sha256s):
                lines.insert(
                    line_number,
                    f"{padding_str}--hash=sha256:{sha256}"
                    + (" \\" if index < len(sha256s) - 1 else ""),
                )
                line_number += 1
            new_content = "\n".join(lines)

        with open(file, "w") as f:
            f.write(new_content)


def update_environment(
    package: str, from_version: str, to_version: str, sha256s: list = None
):
    update_script_files(package, from_version, to_version)
    update_requirements_files(package, from_version, to_version, sha256s)


def update_current(packages: dict, package: str, version: str, sha256s: list = None):
    for group in packages:
        for item in group["items"]:
            if item["name"] == package:
                if item["version"] == version:
                    return False
                update_environment(package, item["version"], version, sha256s)
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


def get_version_from_tag(owner: str, repo: str, prefix: str = "v"):
    url = f"https://api.github.com/repos/{owner}/{repo}/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name: str = tag["name"]
        if "rc" in name:
            continue
        if name.startswith(prefix):
            return name.removeprefix(prefix)
        if prefix == "" and name[0].isdigit():
            return name
    return None


def get_version_from_pypi(project: str):
    url = f"https://pypi.org/pypi/{project}/json"
    with urlopen(url) as f:
        content = json.loads(f.read().decode("utf-8").strip())
    version = content["info"]["version"]
    sha256s = []
    for release in content["releases"][version]:
        sha256s.append(release["digests"]["sha256"])
    return version, sha256s


def get_version_from_release(owner: str, repo: str, prefix: str = "v"):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    with urlopen(url) as f:
        content = json.loads(f.read().decode("utf-8").strip())

    latest: str = content["tag_name"]
    if latest.startswith(prefix):
        latest = latest.removeprefix(prefix)
    return latest


def update_rust(packages: dict):
    latest = get_version_from_release("rust-lang", "rust")
    rust_updated = update_current(packages, "Rust", latest)
    cargo_updated = update_current(packages, "cargo", latest)
    if rust_updated != cargo_updated:
        print("Rust and cargo versions are out of sync")
    return rust_updated


def update_npm(packages: dict):
    latest = get_version_from_release("npm", "cli")
    return update_current(packages, "npm", latest)


def update_pip(packages: dict):
    latest, hashes = get_version_from_pypi("pip")
    return update_current(packages, "pip", latest, hashes)


def update_git(packages: dict):
    latest = get_version_from_tag("git", "git")
    return update_current(packages, "git", latest)


def update_ansible(packages: dict):
    latest = get_version_from_tag("ansible-community", "ansible-build-data", prefix="")
    return update_current(packages, "ansible", latest)


def update_ansible_core(packages: dict):
    latest = get_version_from_release("ansible", "ansible")
    return update_current(packages, "ansible-core", latest)


def update_ansible_lint(packages: dict):
    latest = get_version_from_release("ansible", "ansible-lint")
    return update_current(packages, "ansible-lint", latest)


def update_kubeconform(packages: dict):
    latest = get_version_from_release(
        "yannh",
        "kubeconform",
    )
    return update_current(packages, "kubeconform", latest)


def update_kube_linter(packages: dict):
    latest = get_version_from_release(
        "stackrox",
        "kube-linter",
    )
    return update_current(packages, "kube-linter", latest)


def update_jq(packages: dict):
    latest = get_version_from_tag("jqlang", "jq", prefix="jq-")
    return update_current(packages, "jq", latest)


def update_pipx(packages: dict):
    latest, sha256s = get_version_from_pypi("pipx")
    return update_current(packages, "pipx", latest, sha256s)


def update_typos_cli(packages: dict):
    latest = get_version_from_release("crate-ci", "typos")
    return update_current(packages, "typos-cli", latest)


def update_ruff(packages: dict):
    latest = get_version_from_release("astral-sh", "ruff")
    return update_current(packages, "ruff", latest)


def update_rustup(packages: dict):
    latest = get_version_from_tag("rust-lang", "rustup", prefix="")
    return update_current(packages, "rustup", latest)


def update_yamllint(packages: dict):
    latest = get_version_from_tag("adrienverge", "yamllint")
    return update_current(packages, "yamllint", latest)


def main():
    packages = get_packages()

    checks = {
        "Go": update_go,
        "Node": update_node,
        "Python": update_python,
        "Rust": update_rust,
        "pip": update_pip,
        "pipx": update_pipx,
        "npm": update_npm,
        "git": update_git,
        "ansible": update_ansible,
        "ansible-core": update_ansible_core,
        "ansible-lint": update_ansible_lint,
        "kubeconform": update_kubeconform,
        "kube-linter": update_kube_linter,
        "jq": update_jq,
        "typos-cli": update_typos_cli,
        "ruff": update_ruff,
        "rustup": update_rustup,
        "yamllint": update_yamllint,
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
