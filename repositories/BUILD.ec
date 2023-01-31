# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

filegroup(
    name = "zmake-srcs",
    srcs = glob(["zephyr/zmake/**/*.py"]),
    visibility = ["//visibility:public"],
)

exports_files(glob(["zephyr/**/*"]))
