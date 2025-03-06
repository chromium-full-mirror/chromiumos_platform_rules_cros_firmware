#!/usr/bin/env python3
# Copyright 2024 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Build and bundle an individual AP image.

This is the entry point for the AP firmware recipe.
It gets invoked by chromite/api/controller/firmware.py.
"""

import argparse
import multiprocessing
import os
import subprocess
import sys

# pylint: disable=import-error
from google.protobuf import json_format

# pylint: disable=wrong-import-order
from chromite.api.gen_sdk.chromite.api import firmware_pb2


DEFAULT_BUNDLE_DIRECTORY = "/tmp/artifact_bundles"
DEFAULT_BUNDLE_METADATA_FILE = "/tmp/artifact_bundle_metadata"


def build(_opts):
    """Builds one AP firmware targets.

    Reads FW_NAME from the adjacent firmware_target script,
    and builds that firmware.
    """

    firmware_targets = _opts.firmware_targets.split(",")
    for build_target in firmware_targets:
        cmd = [
            "cros",
            "ap",
            "build",
            f"--build-target={build_target}",
        ]
        subprocess.run(
            cmd,
            check=True,
        )


def test(_opts):
    """Runs all of the unit tests for AP firmware."""


def get_bundle_dir(opts):
    """Get the directory for the bundle from opts or use the default.

    Also create the directory if it doesn't exist.
    """
    if opts.output_dir:
        bundle_dir = opts.output_dir
    else:
        bundle_dir = DEFAULT_BUNDLE_DIRECTORY
    if not os.path.isdir(bundle_dir):
        os.mkdir(bundle_dir)
    return bundle_dir


def write_metadata(opts, info):
    """Write the metadata about the bundle."""
    bundle_metadata_file = (
        opts.metadata if opts.metadata else DEFAULT_BUNDLE_METADATA_FILE
    )
    with open(bundle_metadata_file, "w", encoding="utf-8") as file:
        file.write(json_format.MessageToJson(info))


def bundle(opts):
    """Bundles the artifacts from each target into its own tarball."""
    info = firmware_pb2.FirmwareArtifactInfo()  # pylint: disable=no-member
    info.bcs_version_info.version_string = opts.bcs_version
    bundle_dir = get_bundle_dir(opts)
    firmware_targets = opts.firmware_targets.split(",")
    for build_target in firmware_targets:
        tarball_dir = os.path.join(bundle_dir, build_target)
        if not os.path.isdir(tarball_dir):
            os.mkdir(tarball_dir)
        tarball_name = "firmware_from_source.tar.bz2"
        tarball_path = os.path.join(tarball_dir, tarball_name)
        artifacts_dir = os.path.join("/build", build_target, "firmware")

        cmd = [
            "tar",
            "cvfj",
            tarball_path,
            "--exclude=*.d",
            "--exclude=*.o",
            ".",
        ]
        subprocess.run(
            cmd,
            check=True,
            cwd=artifacts_dir,
        )

        meta = info.objects.add()
        meta.file_name = f"{build_target}/{tarball_name}"
        meta.tarball_info.type = (
            firmware_pb2.FirmwareArtifactInfo.TarballInfo.FirmwareType.MAIN  # pylint: disable=no-member
        )
        meta.tarball_info.firmware_image_name = build_target

        write_metadata(opts, info)


def parse_args(args):
    """Parse all command line args and return opts dict."""
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        "--cpus",
        default=multiprocessing.cpu_count(),
        help="The number of cores to use.",
    )

    parser.add_argument(
        "--firmware-targets",
        required=True,
        help="Comma-separated list of firmware targets (~boards).",
    )

    parser.add_argument(
        "--metrics",
        dest="metrics",
        required=True,
        help="File to write the json-encoded MetricsList proto message.",
    )

    parser.add_argument(
        "--metadata",
        required=False,
        help="Full file pathname to write build artifact metadata in.",
    )

    parser.add_argument(
        "--output-dir",
        required=False,
        help="Full directory pathname to bundle build artifacts in.",
    )

    parser.add_argument(
        "--bcs-version",
        dest="bcs_version",
        default="",
        required=False,
        help="BCS version to include in metadata.",
    )

    sub_cmds = parser.add_subparsers(required=True)

    build_cmd = sub_cmds.add_parser("build", help="Builds all firmware targets")
    build_cmd.set_defaults(func=build)

    test_cmd = sub_cmds.add_parser("test", help="Runs all firmware unit tests")
    test_cmd.set_defaults(func=test)

    test_cmd = sub_cmds.add_parser("bundle", help="Create an artifact tarball.")
    test_cmd.set_defaults(func=bundle)

    return parser.parse_args(args)


def main(args):
    opts = parse_args(args)

    if not hasattr(opts, "func"):
        print("Must select a valid sub command!")
        return -1

    # Run selected sub command function
    opts.func(opts)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
