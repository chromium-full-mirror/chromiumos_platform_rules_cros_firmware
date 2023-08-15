# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@python3_10//:defs.bzl", "interpreter")
load("@rules_python//python:pip.bzl", "pip_parse")

# TODO(b/296101573) Crate problems breaking fwsdk ToT temporarily comment related bazel
#load("@rules_rust//crate_universe:defs.bzl", "crates_repository")
#load("@ti50_rust_deps//:defs.bzl", ti50_rust_deps = "crate_repositories")
#load("@ti50_std_rust_deps//:defs.bzl", ti50_std_rust_deps = "crate_repositories")

def fwsdk_workspace_phase3():
    pip_parse(
        name = "zephyr_py_deps",
        requirements_lock = "//platform/rules_cros_firmware/cros_firmware:zephyr-requirements-lock.txt",
        python_interpreter_target = interpreter,
    )
    pip_parse(
        name = "hdctools_py_deps",
        requirements_lock = "//platform/rules_cros_firmware/cros_firmware:hdctools-requirements-lock.txt",
        python_interpreter_target = interpreter,
    )
    # TODO(b/296101573)
    #ti50_rust_deps()
    #ti50_std_rust_deps()
