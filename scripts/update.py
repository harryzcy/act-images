#!/usr/bin/env python3

import json
from urllib.request import urlopen

padding = 2
padding_str = " " * padding

script_files = [
    "images/ubuntu/{ubuntu_version}/scripts/build.sh",
    "images/ubuntu/{ubuntu_version}/scripts/install.sh",
]

requirements_files = [
    "images/ubuntu/{ubuntu_version}/scripts/requirements-pip.txt",
    "images/ubuntu/{ubuntu_version}/scripts/requirements-pipx.txt",
]


def clean_ubuntu_versions(ubuntu_version: str | None):
    if ubuntu_version is None:
        return ["22.04", "24.04"]
    if ubuntu_version == "noble" or ubuntu_version == "24.04":
        return "24.04"
    if ubuntu_version == "jammy" or ubuntu_version == "22.04":
        return "22.04"
    print(f"Unknown Ubuntu version {ubuntu_version}")


def get_script_files(ubuntu_version: str | None = None):
    files = []
    versions = clean_ubuntu_versions(ubuntu_version)
    for version in versions:
        for file in script_files:
            files.append(file.format(ubuntu_version=version))
    return files


def get_requirements_files(ubuntu_version: str | None = None):
    files = []
    versions = clean_ubuntu_versions(ubuntu_version)
    for version in versions:
        for file in requirements_files:
            files.append(file.format(ubuntu_version=version))
    return files


def get_packages(ubuntu_version: str):
    with open(f"images/ubuntu/{ubuntu_version}/packages.json") as f:
        packages = json.load(f)
    return packages


def write_packages(ubuntu_version: str, packages: dict):
    with open(f"images/ubuntu/{ubuntu_version}/packages.json", "w") as f:
        json.dump(packages, f, indent=2)
        f.write("\n")


def update_script_files(
    package: str,
    from_version: str,
    to_version: str,
    ubuntu_version: str | None = None,
):
    package_env = f"{package.upper().replace('-', '_')}_VERSION"
    old_env = f'{package_env}="{from_version}"'
    new_env = f'{package_env}="{to_version}"'
    for file in get_script_files(ubuntu_version):
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
    package: str,
    from_version: str,
    to_version: str,
    sha256s: list = None,
    ubuntu_version: str | None = None,
):
    old = f"{package}=={from_version}"
    new = f"{package}=={to_version}"
    for file in get_requirements_files(ubuntu_version):
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
    package: str,
    from_version: str,
    to_version: str,
    sha256s: list = None,
    ubuntu_version: str | None = None,
):
    update_script_files(
        package, from_version, to_version, ubuntu_version=ubuntu_version
    )
    update_requirements_files(
        package,
        from_version,
        to_version,
        sha256s=sha256s,
        ubuntu_version=ubuntu_version,
    )


def update_current(
    packages: dict,
    package: str,
    version: str,
    sha256s: list = None,
    ubuntu_version: str | None = None,
):
    if version is None:
        print(f"Failed to get version for {package}")
        return None
    for group in packages:
        for item in group["items"]:
            if item["name"] == package:
                if item["version"] == version:
                    return False
                update_environment(
                    package,
                    item["version"],
                    version,
                    sha256s=sha256s,
                    ubuntu_version=ubuntu_version,
                )
                item["version"] = version
                return True
    return None


def get_version_from_tag(repo: str, prefix: str = "v"):
    url = f"https://api.github.com/repos/{repo}/tags"
    with urlopen(url) as f:
        tags = json.loads(f.read().decode("utf-8").strip())

    for tag in tags:
        name: str = tag["name"]
        if "rc" in name or "a" in name or "b" in name:
            continue
        if prefix != "" and name.startswith(prefix):
            return name.removeprefix(prefix)
        if prefix == "" and name[0].isdigit():
            return name
    return None


def get_version_from_release(repo: str, prefix: str = "v"):
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    with urlopen(url) as f:
        content = json.loads(f.read().decode("utf-8").strip())

    latest: str = content["tag_name"]
    if prefix != "" and latest.startswith(prefix):
        latest = latest.removeprefix(prefix)
    return latest


def get_version_from_pypi(project: str):
    url = f"https://pypi.org/pypi/{project}/json"
    with urlopen(url) as f:
        content = json.loads(f.read().decode("utf-8").strip())
    version = content["info"]["version"]
    sha256s = []
    for release in content["releases"][version]:
        sha256s.append(release["digests"]["sha256"])
    return version, sha256s


def get_version_from_apt(url: str, distribution: str, package: str):
    if distribution not in ["jammy", "noble"]:
        print(f"Unknown distribution {distribution}")
        return None

    url = f"{url}/dists/{distribution}/stable/binary-amd64/Packages"
    with urlopen(url) as f:
        content: str = f.read().decode("utf-8")

    latest = None
    correct_package = False
    for line in content.split("\n"):
        if line.startswith("Package: "):
            correct_package = line.removeprefix("Package: ") == package
        if correct_package and line.startswith("Version: "):
            latest = line.removeprefix("Version: ")
    return latest


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


def update_rust(packages: dict):
    latest = get_version_from_release("rust-lang/rust")
    rust_updated = update_current(packages, "Rust", latest)
    cargo_updated = update_current(packages, "cargo", latest)
    if rust_updated != cargo_updated:
        print("Rust and cargo versions are out of sync")
    return rust_updated


def check(ubuntu_version: str):
    packages = get_packages(ubuntu_version)

    checks = {
        "Go": {
            "source": "custom",
            "function": update_go,
        },
        "Node": {
            "source": "custom",
            "function": update_node,
        },
        "Python": {
            "source": "custom",
            "function": update_python,
        },
        "Rust": {
            "source": "custom",
            "function": update_rust,
        },
        "npm": {
            "source": "github-release",
            "repo": "npm/cli",
        },
        "pip": {
            "source": "pypi",
            "project": "pip",
        },
        "pipx": {
            "source": "pypi",
            "project": "pipx",
        },
        "git": {
            "source": "github-tag",
            "repo": "git/git",
        },
        "ansible": {
            "source": "github-tag",
            "repo": "ansible-community/ansible-build-data",
            "prefix": "",
        },
        "ansible-core": {
            "source": "github-release",
            "repo": "ansible/ansible",
        },
        "ansible-lint": {
            "source": "github-release",
            "repo": "ansible/ansible-lint",
        },
        "docker-ce-cli": {
            "source": "apt",
            "url": "https://download.docker.com/linux/ubuntu",
        },
        "docker-buildx-plugin": {
            "source": "apt",
            "url": "https://download.docker.com/linux/ubuntu",
        },
        "kubeconform": {
            "source": "github-release",
            "repo": "yannh/kubeconform",
        },
        "kube-linter": {
            "source": "github-release",
            "repo": "stackrox/kube-linter",
        },
        "jq": {
            "source": "github-tag",
            "repo": "jqlang/jq",
            "prefix": "jq-",
        },
        "typos-cli": {
            "source": "github-release",
            "repo": "crate-ci/typos",
        },
        "ruff": {
            "source": "github-release",
            "repo": "astral-sh/ruff",
        },
        "rustup": {
            "source": "github-tag",
            "repo": "rust-lang/rustup",
            "prefix": "",
        },
        "yamllint": {
            "source": "github-tag",
            "repo": "adrienverge/yamllint",
        },
    }

    num_updates = 0
    updated_packages = []
    for package, check in checks.items():
        if check["source"] == "custom":
            f = check["function"]
            updated = f(packages)
        elif check["source"] == "github-tag":
            repo = check["repo"]
            prefix = check.get("prefix", "v")
            latest = get_version_from_tag(repo, prefix=prefix)
            updated = update_current(packages, package, latest)
        elif check["source"] == "github-release":
            repo = check["repo"]
            prefix = check.get("prefix", "v")
            latest = get_version_from_release(repo, prefix=prefix)
            updated = update_current(packages, package, latest)
        elif check["source"] == "pypi":
            latest, sha256s = get_version_from_pypi(check["project"])
            updated = update_current(packages, package, latest, sha256s)
        elif check["source"] == "apt":
            latest = get_version_from_apt(check["url"], ubuntu_version, package)
            updated = update_current(
                packages, package, latest, ubuntu_version=ubuntu_version
            )
        else:
            print(f"Unknown source for {package}")
            continue
        if updated:
            num_updates += 1
            updated_packages.append(package)
    if num_updates == 0:
        print("No updates available")
    else:
        write_packages(ubuntu_version, packages)
        print(
            f"Updated {num_updates} packages for {ubuntu_version}:",
            ", ".join(updated_packages),
        )


if __name__ == "__main__":
    for ubuntu_version in ["noble", "jammy"]:
        check(ubuntu_version)
