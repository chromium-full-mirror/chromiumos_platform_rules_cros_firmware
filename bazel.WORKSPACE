# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

workspace(name = "cros_firmware")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "coreboot_sdk",
    build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.coreboot_sdk",
    sha256 = "ff716f2d90432af9b3778e164f0a9a6958a91267008960901bf7be96f5e3db0b",
    urls = [
        "https://storage.googleapis.com/chromeos-localmirror/fwsdk/experimental/distfiles/coreboot-sdk-2022-12-07.tar.zst",
    ],
)
