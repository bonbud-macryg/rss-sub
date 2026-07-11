const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.option(std.builtin.OptimizeMode, "optimize", "Optimization mode") orelse .ReleaseSmall;
    const native_target = b.standardTargetOptions(.{});
    const root = b.path("src/root.zig");

    const tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = root,
        .target = native_target,
        .optimize = .Debug,
    }) });
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Run parser unit tests").dependOn(&run_tests.step);

    const wasm_target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    const wasm = b.addExecutable(.{
        .name = "rss-parser",
        .root_module = b.createModule(.{
            .root_source_file = root,
            .target = wasm_target,
            .optimize = optimize,
            .strip = true,
        }),
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true;
    wasm.export_memory = true;

    const install = b.addInstallArtifact(wasm, .{});
    b.getInstallStep().dependOn(&install.step);
    b.step("wasm", "Build the freestanding WebAssembly parser").dependOn(&install.step);
}
