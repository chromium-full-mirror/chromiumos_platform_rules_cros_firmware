# `rules_cros_firmware`

This repository contains Bazel rules for building AP and EC firmware.
It's the core build logic for the Firmware SDK project.

## Getting Started

At the moment, we have a separate repo manifest in this repository
(see `default.xml`).  This *will* change in the future, and is only
for early experimentation.

To setup the checkout:

``` shellsession
$ mkdir ~/fwsdk
$ cd ~/fwsdk
$ repo init -u https://chromium.googlesource.com/chromiumos/platform/rules_cros_firmware
$ repo sync
```

## Formatting starlark files

The `buildifier` command should be used to auto-format source files.

To install it:

``` shellsession
$ go install github.com/bazelbuild/buildtools/buildifier@latest
```

Make sure `${HOME}/go/bin` is in your `PATH`.

## Submitting changes

At the moment, we do not have CI setup in this repository, and it's
not part of the main ChromeOS build, so changes should be chumped.

At a later point we'll have some CI going.
