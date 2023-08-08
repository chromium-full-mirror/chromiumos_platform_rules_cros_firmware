# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//platform/rules_cros_firmware/repositories:depot_tools.bzl", "depot_tools")
load("//platform/rules_cros_firmware/cros_firmware:bundles.bzl", "bundles_workspace")

def fwsdk_workspace_phase1():
    http_archive(
        name = "bazel_skylib",
        sha256 = "f24ab666394232f834f74d19e2ff142b0af17466ea0c69a3f4c276ee75f6efce",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-1.4.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.0/bazel-skylib-1.4.0.tar.gz",
        ],
    )

    bundles_workspace()

    http_archive(
        name = "coreboot_sdk",
        add_prefix = "coreboot_sdk_root",
        build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.coreboot_sdk",
        sha256 = "f66205d42c86c619f7db1d4d2512fc7235dab9c7ed82e8d0c22dffbd9d8cc50e",
        urls = [
            "https://storage.googleapis.com/chromeos-localmirror/fwsdk/experimental/distfiles/coreboot-sdk-2023-05-12.tar.zst",
        ],
    )

    depot_tools(
        name = "depot_tools",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.depot_tools",
    )

    native.new_local_repository(
        name = "ec",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.ec",
        path = "platform/ec",
    )

    native.new_local_repository(
        name = "zephyr",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.zephyr",
        path = "third_party/zephyr/main",
    )

    native.new_local_repository(
        name = "u_boot",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.u-boot",
        path = "third_party/u-boot",
    )

    native.new_local_repository(
        name = "hdctools",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.hdctools",
        path = "third_party/hdctools",
    )

    native.new_local_repository(
        name = "cmsis",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.cmsis",
        path = "third_party/zephyr/cmsis",
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

    http_archive(
        name = "rules_rust",
        sha256 = "25209daff2ba21e818801c7b2dab0274c43808982d6aea9f796d899db6319146",
        urls = ["https://github.com/bazelbuild/rules_rust/releases/download/0.21.1/rules_rust-v0.21.1.tar.gz"],
    )
