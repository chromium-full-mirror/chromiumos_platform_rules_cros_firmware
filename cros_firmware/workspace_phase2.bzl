# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_python//python:repositories.bzl", "python_register_toolchains")
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("//platform/ti50/common/toolchain:toolchain.bzl", "ti50_deps")

def fwsdk_workspace_phase2():
    python_register_toolchains(
        name = "python3_10",
        # Available versions are listed in @rules_python//python:versions.bzl.
        python_version = "3.10.9",
    )
    bazel_skylib_workspace()

    ti50_deps()
