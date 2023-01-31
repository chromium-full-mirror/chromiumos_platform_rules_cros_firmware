# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_python//python:defs.bzl", "py_binary", "py_library")

py_library(
    name = "zmake-lib",
    srcs = ["@ec//:zmake-srcs"],
)

py_binary(
    name = "zmake-bin",
    srcs = ["@ec//:zephyr/zmake/bazel_main.py"],
    main = "@ec//:zephyr/zmake/bazel_main.py",
    deps = [":zmake-lib"],
)

genrule(
    name = "zmake_list_projects",
    outs = ["zmake_list_projects.log"],
    cmd = "$(PYTHON3) $(locations :zmake-bin) list-projects >& $@",
    toolchains = ["@rules_python//python:current_py_toolchain"],
    tools = [
        ":zmake-bin",
    ],
)
