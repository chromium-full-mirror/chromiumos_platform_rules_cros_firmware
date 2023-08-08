# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@zephyr_py_deps//:requirements.bzl", zephyr_py_deps = "install_deps")
load("@hdctools_py_deps//:requirements.bzl", hdctools_py_deps = "install_deps")

def fwsdk_workspace_phase4():
    zephyr_py_deps()
    hdctools_py_deps()
