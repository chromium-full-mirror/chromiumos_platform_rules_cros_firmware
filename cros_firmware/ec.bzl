# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_skylib//rules:run_binary.bzl", "run_binary")

def ec_image_generator(firmware_target, extra_modules = []):
    # TODO binman inclusion should be in BUILD.ec
    srcs = [
        "@u_boot//:binman_path",
        "@zephyr//:src",
        "@ec//:src",
        "@coreboot_sdk//:coreboot_sdk_root",
    ]

    if "cmsis" in extra_modules:
        srcs += ["@cmsis//:src"]

    build_dir = firmware_target + "_ec_build"

    run_binary(
        name = firmware_target + "_ec",
        srcs = srcs,
        outs = [build_dir],
        args = [
            "--modules-dir",
            "external",
            "--zephyr-base",
            "external/zephyr",
            "build",
            firmware_target,
            "-B",
            "$(location {})".format(build_dir),
            "-t",
            "coreboot-sdk",
            "--extra-cflags='-DCMAKE_BUILD_TYPE=Debug'",
            "-DUSE_CCACHE=0",
        ],
        env = {
            "TOOL_PATH_binman": "$(location @u_boot//:binman_path)",
            "COREBOOT_SDK_ROOT": "$(location @coreboot_sdk//:coreboot_sdk_root)",
        },
        tool = "@ec//:zmake",
    )
