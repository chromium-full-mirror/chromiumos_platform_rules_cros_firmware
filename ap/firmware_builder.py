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
import pathlib
import shlex
import subprocess
import sys
import time

# pylint: disable=import-error
from google.protobuf import json_format

# pylint: disable=wrong-import-order
from chromite.api.gen_sdk.chromite.api import firmware_pb2


DEFAULT_BUNDLE_DIRECTORY = "/tmp/artifact_bundles"
DEFAULT_BUNDLE_METADATA_FILE = "/tmp/artifact_bundle_metadata"

ROOT_DIR = pathlib.Path(__file__).parent.parent.parent.parent.parent.resolve()


def wait_for_processes_early_failure(subprocesses):
    """Waits for all subprocesses to complete.

    Raises an exception immediately if any process exits with a non-zero status.
    Attempts to terminate other running processes upon detecting a failure.

    Args:
        subprocesses: A list of subprocess.Popen objects.

    Raises:
        subprocess.CalledProcessError: If any process returns a non-zero exit
            code.
    """
    running_procs = list(subprocesses)

    while running_procs:
        next_running_procs = []
        failed_proc = None
        returncode = None

        for proc in running_procs:
            retcode = proc.poll()
            if retcode is None:  # Process is still running
                next_running_procs.append(proc)
            else:  # Process has terminated
                if retcode != 0:
                    failed_proc = proc
                    returncode = retcode
                    # Don't break here yet, finish polling to update
                    # next_running_procs so we know which ones to terminate.

        if failed_proc:
            # A process failed. Terminate any other processes that are still
            # running.
            while len(next_running_procs) > 0:
                terminated_procs = []
                for proc in next_running_procs:
                    try:
                        proc.terminate()
                        proc.wait(timeout=1)
                        terminated_procs.append(proc)
                    except ProcessLookupError:
                        pass  # Process finished between poll() and terminate()
                    except TimeoutError:
                        pass  # Process did not terminate in time
                next_running_procs = [
                    item
                    for item in next_running_procs
                    if item not in terminated_procs
                ]
            raise subprocess.CalledProcessError(returncode, failed_proc.args)

        running_procs = next_running_procs

        if running_procs:
            time.sleep(0.01)  # Small sleep to prevent busy-waiting


def build(_opts):
    """Builds one AP firmware targets.

    Reads FW_NAME from the adjacent firmware_target script,
    and builds that firmware.
    """
    env = os.environ.copy()
    if _opts.avb_enabled:
        env["USE"] = "avb"

    firmware_targets = _opts.firmware_targets.split(",")
    subprocesses = []
    for build_target in firmware_targets:
        cmd = [
            "cros",
            "ap",
            "build",
            f"--build-target={build_target}",
        ]
        log_cmd(cmd, env=env)
        subprocesses.append(
            subprocess.Popen(  # pylint: disable=consider-using-with
                cmd, env=env, stdin=subprocess.DEVNULL
            )
        )

    wait_for_processes_early_failure(subprocesses)


def log_cmd(cmd, env=None, cwd=None):
    """Log subprocess command."""
    if cwd:
        print(f"cd {cwd};", end=" ")
    if env is not None:
        print("env", end=" ")
        [  # pylint:disable=expression-not-assigned
            print(key + "=" + shlex.quote(str(value)), end=" ")
            for key, value in env.items()
        ]
    print(" ".join(shlex.quote(str(x)) for x in cmd))
    sys.stdout.flush()


def test(_opts):
    """Runs all of the unit tests for AP firmware."""
    env = os.environ.copy()
    firmware_targets = _opts.firmware_targets.split(",")
    subprocesses = []
    for build_target in firmware_targets:
        cmd = [
            "cros",
            "build-packages",
            "-v",
            "--board",
            build_target,
            "chromeos-base/ec-utils",
        ]
        log_cmd(cmd, env=env)
        subprocesses.append(
            subprocess.Popen(  # pylint: disable=consider-using-with
                cmd, env=env, stdin=subprocess.DEVNULL
            )
        )

    wait_for_processes_early_failure(subprocesses)

    subprocesses = []
    for build_target in firmware_targets:
        cmd = [
            "cros_run_unit_tests",
            "--emerge-verbose",
            "--board",
            build_target,
            "--packages",
            "sys-boot/chromeos-bootimage "
            "sys-boot/coreboot "
            "sys-boot/depthcharge "
            "chromeos-base/vboot_reference",
            "--filter-only-cros-workon",
            "--no-testable-packages-ok",
        ]
        log_cmd(cmd, env=env)
        subprocesses.append(
            subprocess.Popen(  # pylint: disable=consider-using-with
                cmd, env=env, stdin=subprocess.DEVNULL
            )
        )
    wait_for_processes_early_failure(subprocesses)


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

    parser.add_argument(
        "--avb-enabled",
        dest="avb_enabled",
        required=False,
        action="store_true",
        help='Build with the USE="avb".',
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
