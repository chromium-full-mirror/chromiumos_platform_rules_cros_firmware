# Copyright 2024 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/repo:git.bzl", _git_repository = "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("//bazel/repo_defs:cipd.bzl", _cipd_zip_repo = "cipd_zip_repo")
load("//bazel/repo_defs:new_local_repository.bzl", _new_local_repository = "new_local_repository")
load("//platform/cr50-utils:deps.bzl", cr50_deps = "deps")
load("//platform/rules_cros_firmware/repositories:depot_tools.bzl", _depot_tools = "depot_tools")
load("//third_party/lowrisc/opentitan/rules:nonhermetic.bzl", _nonhermetic_repo = "nonhermetic_repo")

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
    new_local_repository = repo_rule_wrapper(_new_local_repository)
    nonhermetic_repo = repo_rule_wrapper(_nonhermetic_repo)
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

    # @coreboot_sdk//* is deprecated, and will be removed after all usages are
    # cleaned up.  Please use @coreboot-sdk-${ARCH}// (below) instead.
    http_archive(
        name = "coreboot_sdk",
        add_prefix = "coreboot_sdk_root",
        build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.coreboot_sdk",
        sha256 = "f66205d42c86c619f7db1d4d2512fc7235dab9c7ed82e8d0c22dffbd9d8cc50e",
        urls = [
            "https://storage.googleapis.com/chromeos-localmirror/fwsdk/experimental/distfiles/coreboot-sdk-2023-05-12.tar.zst",
        ],
    )

    def _coreboot_sdk_subtool(arch, version, sha256):
        http_archive(
            name = "coreboot-sdk-%s" % arch,
            build_file = "//platform/rules_cros_firmware/cros_firmware:BUILD.gcs_subtool",
            sha256 = sha256,
            url = "https://storage.googleapis.com/chromiumos-sdk/toolchains/coreboot-sdk-%s/%s.tar.zst" % (arch, version),
        )

    _coreboot_sdk_subtool(
        "nds32le-elf",
        "11.3.0-r2/47a9bb6b7ef1ea584ed24078ea152a87204a37e1",
        "7299ae598233876ec2f562a1173f8b65de169b1de51cb6e04e003edfb4d04fe7",
    )
    _coreboot_sdk_subtool(
        "i386-elf",
        "11.3.0-r2/5ba88fb0227c76584851bd9cbb24d785e31a717b",
        "72f0b55516120e0919f10ddf28c53a429ccc8132685b6dbd6a8dcefeba92fcc5",
    )
    _coreboot_sdk_subtool(
        "x86_64-elf",
        "11.3.0-r2/7cef840b42c0881fc31eae2031197b844b6fc512",
        "5cd26205b963ca02623e0cc3b53e7eb9725a32d0d08cadfbbb3cf25a6d53c248",
    )
    _coreboot_sdk_subtool(
        "arm-eabi",
        "11.3.0-r2/8adade1392d87565482ea57bfafaf74223cebbe5",
        "312557355983bf732b20dcf7b7553a5b2a13247fc3ad6f21226ff260db1783cd",
    )
    _coreboot_sdk_subtool(
        "aarch64-elf",
        "11.3.0-r2/929d0edbd1d02b5e2c61632d1eb42fe466bf0b69",
        "3a89a034bfafcab8fcc1e6ee24a0b2e785150e9e7892569db0c1f2d54feb8e15",
    )
    _coreboot_sdk_subtool(
        "riscv-elf",
        "11.3.0-r2/c97eb9fef0cf77f9d58d890de4e3e67f5158166f",
        "2345cfbf3dffd2efe0cdfa8d6100a0923d2dc8b77da9d98b9fd07200b18abec1",
    )
    _coreboot_sdk_subtool(
        "iasl",
        "11.3.0-r2/a59cd53c87d0d4e57386c070e9f9a2f1d1cf9b6f",
        "ad1f61b82f13c229e37ac19f43aba835363fed98ff69ff431abf3d11b311bb53",
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

    # ti50-sdk is built by the subtools builder:
    # https://ci.chromium.org/ui/p/chromeos/builders/infra/build-chromiumos-sdk-subtools-ti50-sdk
    # To uprev, visit the above link and copy the URL to the latest sucessful
    # tarball, and update below.  Additionally, this should be kept in sync
    # with the ebuild:
    # src/private-overlays/chromeos-overlay/chromeos-base/chromeos-ti50-dev
    http_archive(
        name = "ti50-sdk",
        integrity = "sha256-XgZxxD6YdzFqibFDZtGfPLl6LI7+pc2v98Qoq0pK+ZQ=",
        build_file = "//platform/ti50/common/toolchain:toolchain.BUILD",
        url = "https://storage.googleapis.com/chromiumos-sdk/toolchains/ti50-sdk/0.0.1-r2/63619045d5e5d32e4eb9160110f2f97bf9a067b7.tar.zst",
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
    cipd_zip_repo(
        name = "codesigner",
        build_file = "//platform/ti50/common/toolchain:codesigner.BUILD",
        url = "cipd://chromeos_internal/infra/tools/cr50-utils:buTaioQouf3i3Hoix1b039uvng4RpflbSRj-7YMkAXoC",
    )

    depot_tools(
        name = "depot_tools",
        build_file = "//platform/rules_cros_firmware/repositories:BUILD.depot_tools",
    )

    cr50_deps(new_local_repository = new_local_repository)

    nonhermetic_repo(name = "nonhermetic")

    return module_ctx.extension_metadata(
        root_module_direct_deps = generated_repos,
        root_module_direct_dev_deps = [],
        reproducible = True,
    )

fwsdk_deps = module_extension(
    implementation = _fwsdk_deps_impl,
)
