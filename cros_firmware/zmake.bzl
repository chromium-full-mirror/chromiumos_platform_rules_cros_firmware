# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

script_template = """\
#!/bin/bash

OUTPUT_FILE=$1
set -x
pwd >> $OUTPUT_FILE

COREBOOT_SDK_ROOT="{coreboot_root}"

echo "COREBOOT_SDK_ROOT from Bazel is $COREBOOT_SDK_ROOT" >> $OUTPUT_FILE
echo "Running ls on COREBOOT_SDK_ROOT" >> $OUTPUT_FILE
ls $COREBOOT_SDK_ROOT >> $OUTPUT_FILE

# TODO - Get vpython3 working in build rule or as separate run rule
# cd ~/fwsdk/src/platform/ec/zephyr/zmake/
# export PATH="$PATH:$HOME/fwsdk/src/third_party/u-boot/files/tools/binman"
# vpython3 -m zmake -D -j1 build herobrine -DCOREBOOT_SDK_ROOT=$COREBOOT_SDK_ROOT -t coreboot-sdk -DPYTHON_PREFER=/home/aaronmassey/depot_tools/vpython3 -DPython3_EXECUTABLE=/home/aaronmassey/depot_tools/vpython3
"""

def _zmake_build_herobrine_impl(ctx):
    # Emit the executable shell script.
    script = ctx.actions.declare_file("zmake_build_herobrine")
    script_content = script_template.format(
        coreboot_root = ctx.file._sdk.path,
    )
    ctx.actions.write(script, script_content, is_executable = True)

    output = ctx.actions.declare_file("zmake_out.log")

    print("Check script output at {}".format(output.path))

    args = ctx.actions.args()

    args.add(output)

    ctx.actions.run(executable = script, outputs = [output], inputs = [ctx.file._sdk], arguments = [args])

    return [DefaultInfo(files = depset([output]))]

zmake_build_herobrine = rule(
    implementation = _zmake_build_herobrine_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "deps": attr.label_list(allow_files = True),
        "_sdk": attr.label(default = Label("@coreboot_sdk//:coreboot_sdk_root"), allow_single_file = True),
    },
)
