# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

workspace(name = "cros_firmware")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//platform/rules_cros_firmware/repositories:depot_tools.bzl", "depot_tools")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "f24ab666394232f834f74d19e2ff142b0af17466ea0c69a3f4c276ee75f6efce",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-1.4.0.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-1.4.0.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "coreboot_sdk",
    add_prefix = "coreboot_sdk_root",
    build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.coreboot_sdk",
    sha256 = "ff716f2d90432af9b3778e164f0a9a6958a91267008960901bf7be96f5e3db0b",
    urls = [
        "https://storage.googleapis.com/chromeos-localmirror/fwsdk/experimental/distfiles/coreboot-sdk-2022-12-07.tar.zst",
    ],
)

depot_tools(
    name = "depot_tools",
    build_file = "//platform/rules_cros_firmware/repositories:BUILD.depot_tools",
)

new_local_repository(
    name = "ec",
    build_file = "//platform/rules_cros_firmware/repositories:BUILD.ec",
    path = "platform/ec",
)

new_local_repository(
    name = "zephyr",
    build_file = "//platform/rules_cros_firmware/repositories:BUILD.zephyr",
    path = "third_party/zephyr/main",
)

new_local_repository(
    name = "u_boot",
    build_file = "//platform/rules_cros_firmware/repositories:BUILD.u-boot",
    path = "third_party/u-boot",
)

rules_python_version = "0.17.3"

http_archive(
    name = "rules_python",
    sha256 = "8c15896f6686beb5c631a4459a3aa8392daccaab805ea899c9d14215074b60ef",
    strip_prefix = "rules_python-{}".format(rules_python_version),
    urls = [
        "https://github.com/bazelbuild/rules_python/archive/refs/tags/{}.tar.gz".format(rules_python_version),
    ],
)

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python3_10",
    # Available versions are listed in @rules_python//python:versions.bzl.
    python_version = "3.10.9",
)

load("@rules_python//python:pip.bzl", "pip_parse")

pip_parse(
    name = "zephyr_py_deps",
    requirements_lock = "//platform/rules_cros_firmware/cros_firmware:zephyr-requirements-lock.txt",
)

load("@zephyr_py_deps//:requirements.bzl", "install_deps")

install_deps()
