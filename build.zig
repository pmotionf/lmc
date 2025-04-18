const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const build_zig_zon = b.createModule(.{
        .root_source_file = b.path("build.zig.zon"),
        .target = target,
        .optimize = optimize,
    });

    const lmc = b.addModule("lmc", .{
        .root_source_file = b.path("src/lmc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "build.zig.zon", .module = build_zig_zon },
        },
    });

    const link_option = b.option(
        std.builtin.LinkMode,
        "link",
        "Link mode of emitted library artifact",
    ) orelse .static;

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lmc", .module = lmc },
        },
    });

    const lib = b.addLibrary(.{
        .linkage = link_option,
        .name = "lmc",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
