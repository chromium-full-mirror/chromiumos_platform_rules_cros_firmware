# Copyright 2024 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("//bazel/repo_defs:cipd.bzl", _cipd_zip_repo = "cipd_zip_repo")
load("//bazel/repo_defs:new_local_repository.bzl", _new_local_repository = "new_local_repository")
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
    new_local_repository = repo_rule_wrapper(_new_local_repository)
    cipd_zip_repo = repo_rule_wrapper(_cipd_zip_repo)

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

    new_local_repository(
        name = "ec",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.ec",
        path = "platform/ec",
    )

    new_local_repository(
        name = "zephyr",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.zephyr",
        path = "third_party/zephyr/main",
    )

    new_local_repository(
        name = "u_boot",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.u-boot",
        path = "third_party/u-boot",
    )

    new_local_repository(
        name = "hdctools",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.hdctools",
        path = "third_party/hdctools",
    )

    new_local_repository(
        name = "cmsis",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.cmsis",
        path = "third_party/zephyr/cmsis",
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
