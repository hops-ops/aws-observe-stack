#!/usr/bin/env python3

import re
import subprocess
import sys


def ensure_yaml():
    try:
        import yaml  # type: ignore
    except Exception:
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "--user", "PyYAML"]
        )
        import yaml  # type: ignore
    return yaml


def main():
    if len(sys.argv) != 3:
        raise SystemExit(
            "Usage: scripts/generate_configuration_metadata.py <upbound.yaml> <output.yaml>"
        )

    yaml = ensure_yaml()
    in_file, out_file = sys.argv[1], sys.argv[2]

    with open(in_file, "r", encoding="utf-8") as f:
        project = yaml.safe_load(f) or {}

    metadata = project.get("metadata") or {}
    spec = project.get("spec") or {}

    name = metadata.get("name")
    if not name:
        raise SystemExit("upbound.yaml is missing metadata.name")

    maintainer = spec.get("maintainer", "")
    if isinstance(maintainer, str):
        maintainer = re.sub(r"\s*<[^>]+>\s*$", "", maintainer).strip()

    annotations = {
        "meta.crossplane.io/maintainer": maintainer,
        "meta.crossplane.io/source": spec.get("source", ""),
        "meta.crossplane.io/description": spec.get("description", ""),
    }

    depends_on = []
    for dep in spec.get("dependsOn") or []:
        if not isinstance(dep, dict):
            continue

        kind = str(dep.get("kind", "")).strip().lower()
        package = dep.get("package")
        version = dep.get("version")
        if not package:
            continue

        if kind == "provider":
            item = {"provider": package}
        elif kind == "function":
            item = {"function": package}
        elif kind == "configuration":
            item = {"configuration": package}
        else:
            continue

        if version is not None:
            item["version"] = version
        depends_on.append(item)

    output = {
        "apiVersion": "meta.pkg.crossplane.io/v1alpha1",
        "kind": "Configuration",
        "metadata": {
            "name": name,
            "annotations": {k: v for k, v in annotations.items() if v},
        },
        "spec": {
            "dependsOn": depends_on,
        },
    }

    with open(out_file, "w", encoding="utf-8") as f:
        yaml.safe_dump(output, f, sort_keys=False)

    print(f"Wrote {out_file}")


if __name__ == "__main__":
    main()
