TOOLS = [
    "ar",
    "as",
    "ld",
    "ld.bfd",
    "ld.gold",
    "nm",
    "objcopy",
    "objdump",
    "ranlib",
    "readelf",
    "strip",
]

ARCHES = [
    "aarch64-elf",
    "arm-eabi",
    "i386-elf",
    "nds32le-elf",
    "riscv64-elf",
    "x86_64-elf",
]

VERSION = "11.2.0"

# {arch}/bin/{TOOLS}
# {arch}/lib/*
# bin/{arch}-{TOOLS}
# lib/gcc/{arch}/{VERSION}/
#   include/*.h
#

def filemaps(name = ""):
    for arch in ARCHES:
        native.filegroup(
            name = "{name}{arch}_ldscripts".format(arch = arch, name = name),
            srcs = native.glob(["{arch}/lib/**/*".format(arch = arch)]),
        )

        native.filegroup(
            name = "{name}{arch}_includes".format(arch = arch, name = name),
            srcs = native.glob(["lib/gcc/{arch}/{version}/include/*.h".format(arch = arch, version = VERSION)]),
        )

        for tool in TOOLS:
            native.filegroup(
                name = "{name}{arch}_{tool}".format(arch = arch, tool = tool, name = name),
                srcs = ["bin/{arch}-{tool}".format(arch = arch, tool = tool), "{arch}/bin/{tool}".format(arch = arch, tool = tool)],
            )
