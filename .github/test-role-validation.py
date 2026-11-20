#!/usr/bin/env python3
"""Check role validation and selector compatibility using Helm rendering."""

import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


CHART = Path(__file__).resolve().parents[1] / "charts" / "vector"
VALID_ROLES = (
    ("Agent", "DaemonSet"),
    ("Aggregator", "StatefulSet"),
    ("Stateless-Aggregator", "Deployment"),
)


class RoleValidation(unittest.TestCase):
    def render(self, values, *, upgrade=False, chart=CHART):
        args = ["helm", "template", "role-test", str(chart), "-f", "-",
                "--api-versions", "monitoring.coreos.com/v1"]
        if upgrade:
            args.append("--is-upgrade")
        return subprocess.run(args, input=json.dumps(values),
                              text=True, capture_output=True)

    def assert_invalid(self, result):
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("role", result.stderr)
        self.assertIn("Agent, Aggregator, or Stateless-Aggregator", result.stderr)
        self.assertEqual(result.stdout.strip(), "")

    def test_role_casing_and_selectors(self):
        for role, kind in VALID_ROLES:
            mixed = "".join(char.upper() if index % 2 else char.lower()
                            for index, char in enumerate(role))
            for value in (role, role.lower(), role.upper(), mixed):
                for upgrade in (False, True):
                    with self.subTest(role=value, upgrade=upgrade):
                        result = self.render({
                            "role": value,
                            "podDisruptionBudget": {"enabled": True},
                            "podMonitor": {"enabled": True},
                        }, upgrade=upgrade)
                        self.assertEqual(result.returncode, 0, result.stderr)
                        workloads = re.findall(
                            r"(?m)^kind: (DaemonSet|StatefulSet|Deployment)$",
                            result.stdout,
                        )
                        self.assertEqual(workloads, [kind])
                        for resource in ("Service", "PodDisruptionBudget", "PodMonitor"):
                            self.assertIn("kind: " + resource + "\n", result.stdout)
                        components = re.findall(
                            r"(?m)^\s+app\.kubernetes\.io/component: (.+)$",
                            result.stdout,
                        )
                        self.assertGreaterEqual(len(components), 4)
                        self.assertEqual(set(components), {value})

    def test_default_role(self):
        implicit = self.render({})
        explicit = self.render({"role": "Aggregator"})
        self.assertEqual(implicit.returncode, 0, implicit.stderr)
        self.assertEqual(explicit.returncode, 0, explicit.stderr)
        self.assertEqual(implicit.stdout, explicit.stdout)
        self.assertIn("kind: StatefulSet\n", implicit.stdout)

    def test_invalid_roles(self):
        for role in ("Agnet", "none", "", " Agent ", 123, True, None, [], {}):
            for upgrade in (False, True):
                with self.subTest(role=role, upgrade=upgrade):
                    self.assert_invalid(self.render({"role": role}, upgrade=upgrade))

    def test_validation_with_resources_disabled(self):
        # This previously rendered an empty chart instead of a Vector workload.
        values = {
            "role": "none",
            "service": {"enabled": False},
            "serviceHeadless": {"enabled": False},
            "serviceAccount": {"create": False},
            "existingConfigMaps": ["external-vector-config"],
        }
        for upgrade in (False, True):
            with self.subTest(upgrade=upgrade):
                self.assert_invalid(self.render(values, upgrade=upgrade))

    def test_disabled_subchart(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory)
            (parent / "Chart.yaml").write_text(
                "apiVersion: v2\nname: role-parent\nversion: 0.1.0\n"
                "dependencies:\n  - name: vector\n    version: '*'\n"
                "    condition: vector.enabled\n"
            )
            shutil.copytree(CHART, parent / "charts" / "vector")
            for upgrade in (False, True):
                with self.subTest(upgrade=upgrade):
                    result = self.render({"vector": {"enabled": False, "role": "none"}},
                                         upgrade=upgrade, chart=parent)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout.strip(), "")


if __name__ == "__main__":
    unittest.main()
