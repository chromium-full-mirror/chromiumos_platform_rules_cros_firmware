# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

filegroup(
    name = "zmake_src",
    srcs = glob(["zephyr/zmake/**/*.py"]),
)

filegroup(
    name = "src",
    srcs = glob([
        "builtin/**",
        "common/**",
        "driver/**",
        "include/**",
        "power/**",
        "zephyr/**",
        "fuzz/**",
        "test/**",
        "*",
    ]),
    visibility = ["//visibility:public"],
)

py_binary(
    name = "zmake",
    srcs = [":zmake_src"],
    data = [
        "@ec//:src",
    ],
    main = "//:zephyr/zmake/bazel_main.py",
    visibility = ["//visibility:public"],
    deps = ["@zephyr//:py_deps", "@u_boot//:binman"],
)
