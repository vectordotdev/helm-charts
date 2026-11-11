#!/usr/bin/env python3
"""Render image options without pulling images or installing a chart."""

import json
from pathlib import Path
import re
import subprocess
import unittest


CHART = Path(__file__).resolve().parents[1] / "charts" / "vector"
REPOSITORY = "example.com/team/haproxy"
DIGEST = "sha256:" + "a" * 64
OTHER_DIGEST = "sha256:" + "b" * 64
LABEL = re.compile(r"[A-Za-z0-9](?:[A-Za-z0-9_.-]{0,61}[A-Za-z0-9])?")


class ImageReferences(unittest.TestCase):
    def render(self, values):
        result = subprocess.run(
            ["helm", "template", "image-test", str(CHART), "-f", "-"],
            input=json.dumps(values), text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        sources = list(re.finditer(r"(?m)^# Source: (.+)\n", result.stdout))
        return {
            source[1]: result.stdout[source.end():sources[index + 1].start()]
            if index + 1 < len(sources) else result.stdout[source.end():]
            for index, source in enumerate(sources)
        }

    def image(self, document):
        images = re.findall(r"(?m)^\s+image: (.+)$", document)
        self.assertEqual(len(images), 1)
        return json.loads(images[0])

    def test_haproxy_images_and_labels(self):
        # None means that the version label must be omitted.
        cases = [
            ("defaults", {}, "haproxytech/haproxy-alpine:2.6.12", "2.6.12"),
            ("tag", {"tag": "2.8"}, REPOSITORY + ":2.8", "2.8"),
            ("numeric tag", {"tag": 3}, REPOSITORY + ":3", "3"),
            ("raw sha", {"sha": "a" * 64}, REPOSITORY + ":2.6.12@" + DIGEST, "2.6.12"),
            ("prefixed sha", {"sha": DIGEST}, REPOSITORY + ":2.6.12@" + DIGEST, "2.6.12"),
            ("digest alias", {"digest": DIGEST}, REPOSITORY + ":2.6.12@" + DIGEST, "2.6.12"),
            ("sha precedence", {"sha": DIGEST, "digest": OTHER_DIGEST},
             REPOSITORY + ":2.6.12@" + DIGEST, "2.6.12"),
            ("empty tag with sha", {"tag": "", "sha": DIGEST}, REPOSITORY + "@" + DIGEST, None),
            ("null tag with sha", {"tag": None, "sha": DIGEST}, REPOSITORY + "@" + DIGEST, None),
            ("empty tag", {"tag": ""}, REPOSITORY + ":latest", None),
            ("null tag", {"tag": None}, REPOSITORY + ":latest", None),
            ("digest tag", {"tag": DIGEST}, REPOSITORY + "@" + DIGEST, None),
            ("combined tag", {"tag": "2.8@" + OTHER_DIGEST},
             REPOSITORY + ":2.8@" + OTHER_DIGEST, "2.8"),
            ("replace combined digest", {"tag": "2.8@" + OTHER_DIGEST, "sha": DIGEST},
             REPOSITORY + ":2.8@" + DIGEST, "2.8"),
            ("replace digest tag", {"tag": OTHER_DIGEST, "sha": DIGEST},
             REPOSITORY + "@" + DIGEST, None),
            ("invalid label tag", {"tag": "_debug"}, REPOSITORY + ":_debug", None),
            ("long label tag", {"tag": "x" * 64}, REPOSITORY + ":" + "x" * 64, None),
            ("maximum label tag", {"tag": "x" * 63}, REPOSITORY + ":" + "x" * 63, "x" * 63),
        ]
        for name, image, expected_image, expected_label in cases:
            with self.subTest(name=name):
                if name != "defaults":
                    image = {"repository": REPOSITORY, **image}
                documents = self.render({"haproxy": {
                    "enabled": True, "image": image, "autoscaling": {"enabled": True},
                }})
                haproxy = {
                    path: document for path, document in documents.items()
                    if path.startswith("vector/templates/haproxy/")
                }
                self.assertEqual(set(haproxy), {
                    "vector/templates/haproxy/" + name + ".yaml"
                    for name in ("configmap", "serviceaccount", "service", "deployment", "hpa")
                })
                self.assertEqual(self.image(haproxy["vector/templates/haproxy/deployment.yaml"]),
                                 expected_image)
                for path, document in haproxy.items():
                    labels = re.findall(r"(?m)^\s+app\.kubernetes\.io/version: (.*)$", document)
                    self.assertEqual(labels, [] if expected_label is None else [json.dumps(expected_label)], path)
                    for label in labels:
                        self.assertIsNotNone(LABEL.fullmatch(json.loads(label)), path)

    def test_vector_digest_precedence(self):
        for tag, expected in [
            ("1.2.3@" + OTHER_DIGEST, "example.com/team/vector:1.2.3@" + DIGEST),
            (OTHER_DIGEST, "example.com/team/vector@" + DIGEST),
        ]:
            with self.subTest(tag=tag):
                documents = self.render({"image": {
                    "repository": "example.com/team/vector", "tag": tag, "sha": DIGEST,
                }})
                self.assertEqual(self.image(documents["vector/templates/statefulset.yaml"]), expected)


if __name__ == "__main__":
    unittest.main()
