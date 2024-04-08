# Copyright 2024 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/repo:git.bzl", _git_repository = "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("//platform/rules_cros_firmware/repositories:depot_tools.bzl", _depot_tools = "depot_tools")

def _fwsdk_deps_impl(module_ctx):
    generated_repos = []

    # Calls the repo rule, but also adds an annotation to MODULE.bazel so that
    # we can automatically add use_repo on it.
    def repo_rule_wrapper(repo_rule):
        def new_fn(*, name, **kwargs):
            repo_rule(name = name, **kwargs)
            generated_repos.append(name)

        return new_fn

    http_archive = repo_rule_wrapper(_http_archive)
    depot_tools = repo_rule_wrapper(_depot_tools)
    git_repository = repo_rule_wrapper(_git_repository)

    http_archive(
        name = "ec_devutils",
        add_prefix = "bundle",
        build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.bundle",
        sha256 = "4626ca7ef3d53c182b7517fe7e67d123291ed39c0196b4efb83fb4cb24bf3b37",
        urls = [
            "https://storage.googleapis.com/chromeos-localmirror/fwsdk/bundles/chromeos-base/ec-devutils-0.0.2-r13228.tar.zst",
        ],
    )
    http_archive(
        name = "shflags",
        add_prefix = "bundle",
        build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.bundle",
        sha256 = "0f829b2ee406630a08f5ee60905a2d5d52ee9154b0133c7185405a479aa58286",
        urls = [
            "https://storage.googleapis.com/chromeos-localmirror/fwsdk/bundles/dev-util/shflags-1.2.3-r1.tar.zst",
        ],
    )

    http_archive(
        name = "coreboot_sdk",
        add_prefix = "coreboot_sdk_root",
        build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.coreboot_sdk",
        sha256 = "f66205d42c86c619f7db1d4d2512fc7235dab9c7ed82e8d0c22dffbd9d8cc50e",
        urls = [
            "https://storage.googleapis.com/chromeos-localmirror/fwsdk/experimental/distfiles/coreboot-sdk-2023-05-12.tar.zst",
        ],
    )

    # To create an SDK , copy /opt/ti50-sdk/* to a new directory.
    # From the chroot, copy the following in <sdk>/lib
    # libc++abi.so.1
    # libc++.so.1
    # libgcc_s.so.1
    # libm.so.6
    # libtinfo.so.6
    # libunwind.so.1
    # libz.so.1
    # libzstd.so.1
    # Copy libc.so.6 from the host to <sdk>/lib
    # Package with:
    # tar -I zstd -cvf ti50-sdk_yyyy_mm_dd.tar.zst ./*
    # Upload to fwsdk experimental directory:
    # gsutil cp ti50-sdk_yyyy_mm_dd.tar.zst gs://chromeos-localmirror/fwsdk/experimental/distfiles/
    # Set permissions to public:
    # gsutil setacl public-read gs://chromeos-localmirror/fwsdk/experimental/distfiles/ti50-sdk_yyyy_mm_dd.tar.zst
    # Update url and sha256 below.
    http_archive(
        name = "ti50-sdk",
        sha256 = "8099a9d1c4eb36ba13ee8d9592d359101e62d21174149361398113cc1818e690",
        build_file = "//platform/ti50/common/toolchain:toolchain.BUILD",
        # TODO(b/285214418): Move out of experimental.
        url = "https://storage.googleapis.com/chromeos-localmirror/fwsdk/experimental/distfiles/ti50-sdk_2023_08_31.tar.zst",
    )
    http_archive(
        name = "cros-sdk",
        sha256 = "99cbebb56f82a299aad54e6fdc0f1215b5544003ee53ab2e3c701970d659c6d0",
        build_file = "//platform/ti50/common/toolchain:cros_sdk.BUILD",
        url = "https://storage.googleapis.com/chromiumos-sdk/2023/05/x86_64-cros-linux-gnu-2023.05.04.004234.tar.xz",
    )
    git_repository(
        name = "compiler-builtins",
        remote = "https://github.com/rust-lang/compiler-builtins",
        tag = "0.1.84",
        build_file = "//platform/ti50/common/toolchain:compiler-builtins.BUILD",
    )

    depot_tools(
        name = "depot_tools",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.depot_tools",
    )

    return module_ctx.extension_metadata(
        root_module_direct_deps = generated_repos,
        root_module_direct_dev_deps = [],
        reproducible = True,
    )

fwsdk_deps = module_extension(
    implementation = _fwsdk_deps_impl,
)
