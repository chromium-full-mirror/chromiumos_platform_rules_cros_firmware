# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_python//python:defs.bzl", "py_binary", "py_library")
load("@rules_python//python:pip.bzl", "pip_install")
load("@bazel_skylib//rules:run_binary.bzl", "run_binary")

# Next steps for build_krabby:
# Current failure: binman: cannot import name 'QUIET_NOTFOUND' from 'libfdt' (unknown location)
# Seems like we're going to need to have a compiled u-boot to depend on.

# TODO binman inclusion should be in BUILD.ec
run_binary(
    name = "build_krabby",
    srcs = [
        "@ec//:ec_src",
        "@u_boot//:binman_path",
        "@zephyr//:src",
    ],
    outs = ["krabby.log"],
    args = [
        "--modules-dir",
        "external",
        "--zephyr-base",
        "external/zephyr",
        "build",
        "krabby",
        "--extra-cflags='-DCMAKE_BUILD_TYPE=Debug'",
        "-DUSE_CCACHE=0",
    ],
    env = {"TOOL_PATH_binman": "$(location @u_boot//:binman_path)"},
    tool = "@ec//:zmake",
)
