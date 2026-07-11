const std = @import("std");

const Action = enum {
    build,
    clean,
    clear,
};

const RepoImport = struct {
    name: []const u8,
    url: []const u8,
    commit: []const u8,
    prefix: []const u8,
    paths: []const []const u8,
};

const dependencies = [1]RepoImport{
    .{
        .name = "base-dev",
        .url = "https://github.com/urbit/urbit",
        .commit = "0f94550b941dfe046d9dff4a541330bd084e8cd1",
        .prefix = "pkg/base-dev",
        .paths = &.{
            "lib/dbug.hoon",
            "lib/default-agent.hoon",
            "lib/skeleton.hoon",
            "lib/strand.hoon",
            "lib/strandio.hoon",
            "lib/test.hoon",
            "lib/verb.hoon",
            "lib/wasm/lia.hoon",
            "lib/wasm/parser.hoon",
            "lib/wasm/validator.hoon",
            "lib/wasm/runner/engine.hoon",
            "lib/wasm/runner/op-def.hoon",
            "mar/bill.hoon",
            "mar/kelvin.hoon",
            "mar/mime.hoon",
            "mar/wasm.hoon",
            "sur/spider.hoon",
            "sur/verb.hoon",
            "sur/wasm/engine.hoon",
            "sur/wasm/lia.hoon",
            "sur/wasm/wasm.hoon",
        },
    },
};

const dependency_cache_dir = ".zig-cache/desk-deps";

const DeskStep = struct {
    step: std.Build.Step,
    action: Action,
    copy_target: ?[]const u8,

    fn create(b: *std.Build, name: []const u8, action: Action, copy_target: ?[]const u8) *DeskStep {
        const self = b.allocator.create(DeskStep) catch @panic("OOM");
        self.* = .{
            .step = std.Build.Step.init(.{
                .id = .custom,
                .name = name,
                .owner = b,
                .makeFn = make,
            }),
            .action = action,
            .copy_target = copy_target,
        };
        return self;
    }

    fn make(step: *std.Build.Step, options: std.Build.Step.MakeOptions) !void {
        _ = options;
        const self: *DeskStep = @fieldParentPtr("step", step);
        const allocator = step.owner.allocator;

        switch (self.action) {
            .build => try buildDesk(step, allocator, self.copy_target),
            .clean => try clean(),
            .clear => try clear(),
        }
    }
};

pub fn build(b: *std.Build) void {
    const desk = b.option([]const u8, "desk", "After building, replace the desk at this path with /dist contents");

    const build_step = DeskStep.create(b, "build desk", .build, desk);
    b.default_step.dependOn(&build_step.step);

    const named_build = b.step("build", "Build /dist from /desk and dependencies");
    named_build.dependOn(&build_step.step);

    const clean_step = DeskStep.create(b, "clean", .clean, null);
    const named_clean = b.step("clean", "Remove /dist");
    named_clean.dependOn(&clean_step.step);

    const clear_step = DeskStep.create(b, "clear", .clear, null);
    const named_clear = b.step("clear", "Remove /dist and cached dependencies");
    named_clear.dependOn(&clear_step.step);
}

fn buildDesk(step: *std.Build.Step, allocator: std.mem.Allocator, copy_target: ?[]const u8) !void {
    if (!pathExists("desk") and !pathExists("desk-dev")) {
        return step.fail("neither /desk nor /desk-dev directory found", .{});
    }

    std.debug.print("Creating /dist directory...\n", .{});
    try recreateDir("dist");

    if (pathExists("desk-dev")) {
        std.debug.print("Copying /desk-dev to /dist...\n", .{});
        try copyDirContents(allocator, "desk-dev", "dist");
    }

    if (pathExists("desk")) {
        std.debug.print("Copying /desk to /dist...\n", .{});
        try copyDirContents(allocator, "desk", "dist");
    }

    try buildParser(step);

    for (dependencies) |dep| {
        try importDependency(step, allocator, dep, "dist");
    }

    std.debug.print("Built!\n", .{});

    if (copy_target) |target| {
        const target_path = try expandHomePath(allocator, step, target);
        try copyDistToTarget(allocator, step, target_path);
    }
}

fn buildParser(step: *std.Build.Step) !void {
    std.debug.print("Building RSS parser Wasm module...\n", .{});
    try run(step, &.{ "zig", "build", "--build-file", "parser/build.zig", "wasm" });
    const source_path = "parser/zig-out/bin/rss-parser.wasm";
    if (!pathExists(source_path)) return step.fail("parser did not produce {s}", .{source_path});
    try copyFilePath(source_path, "dist/wasm/rss-parser.wasm");
}

fn clean() !void {
    try deleteTreeIfExists("dist");
}

fn clear() !void {
    try clean();
    try deleteTreeIfExists(dependency_cache_dir);
}

fn importDependency(
    step: *std.Build.Step,
    allocator: std.mem.Allocator,
    dep: RepoImport,
    dist_path: []const u8,
) !void {
    const repo_path = try std.fs.path.join(allocator, &.{ dependency_cache_dir, dep.name });

    try ensureRepoImport(step, repo_path, dep);

    for (dep.paths) |path| {
        const import_path = try prefixedPath(allocator, dep.prefix, path);
        const rel = strippedPath(dep.prefix, path);
        const source_path = try std.fs.path.join(allocator, &.{ repo_path, import_path });
        const dest_path = try std.fs.path.join(allocator, &.{ dist_path, rel });
        try copyFilePath(source_path, dest_path);
    }
}

fn ensureRepoImport(step: *std.Build.Step, repo_path: []const u8, dep: RepoImport) !void {
    const git_dir = try std.fs.path.join(step.owner.allocator, &.{ repo_path, ".git" });
    if (!pathExists(git_dir)) {
        if (std.fs.path.dirname(repo_path)) |parent| {
            try std.fs.cwd().makePath(parent);
        }
        try std.fs.cwd().makePath(repo_path);
        std.debug.print("Importing {s}...\n", .{dep.name});
        try run(step, &.{ "git", "-C", repo_path, "init" });
        try run(step, &.{ "git", "-C", repo_path, "remote", "add", "origin", dep.url });
        try run(step, &.{ "git", "-C", repo_path, "sparse-checkout", "init", "--no-cone" });
    }

    try setSparseCheckout(step, dep, repo_path);

    if (!gitHasCommit(step, repo_path, dep.commit)) {
        try run(step, &.{ "git", "-C", repo_path, "fetch", "--depth", "1", "--filter=blob:none", "origin", dep.commit });
    }

    try run(step, &.{ "git", "-C", repo_path, "checkout", "--detach", "--force", dep.commit });
}

fn setSparseCheckout(step: *std.Build.Step, dep: RepoImport, repo_path: []const u8) !void {
    var argv = std.ArrayList([]const u8){};
    try argv.append(step.owner.allocator, "git");
    try argv.append(step.owner.allocator, "-C");
    try argv.append(step.owner.allocator, repo_path);
    try argv.append(step.owner.allocator, "sparse-checkout");
    try argv.append(step.owner.allocator, "set");
    try argv.append(step.owner.allocator, "--no-cone");
    for (dep.paths) |path| {
        try argv.append(step.owner.allocator, try prefixedPath(step.owner.allocator, dep.prefix, path));
    }
    try run(step, argv.items);
}

fn gitHasCommit(step: *std.Build.Step, repo_path: []const u8, commit: []const u8) bool {
    const commit_ref = std.fmt.allocPrint(step.owner.allocator, "{s}^{{commit}}", .{commit}) catch return false;
    return runAllowFail(step, &.{ "git", "-C", repo_path, "cat-file", "-e", commit_ref });
}

fn run(step: *std.Build.Step, argv: []const []const u8) !void {
    const result = std.process.Child.run(.{
        .allocator = step.owner.allocator,
        .argv = argv,
        .max_output_bytes = 256 * 1024,
    }) catch |err| {
        return step.fail("failed to run {s}: {s}", .{ argv[0], @errorName(err) });
    };

    switch (result.term) {
        .Exited => |code| {
            if (code == 0) return;
            if (result.stderr.len > 0) {
                std.debug.print("{s}", .{result.stderr});
            }
            return step.fail("command exited with code {d}: {s}", .{ code, argv[0] });
        },
        else => {
            if (result.stderr.len > 0) {
                std.debug.print("{s}", .{result.stderr});
            }
            return step.fail("command failed: {s}", .{argv[0]});
        },
    }
}

fn runAllowFail(step: *std.Build.Step, argv: []const []const u8) bool {
    const result = std.process.Child.run(.{
        .allocator = step.owner.allocator,
        .argv = argv,
        .max_output_bytes = 256 * 1024,
    }) catch return false;

    return switch (result.term) {
        .Exited => |code| code == 0,
        else => false,
    };
}

fn prefixedPath(allocator: std.mem.Allocator, prefix: []const u8, path: []const u8) ![]const u8 {
    if (prefix.len == 0 or hasPathPrefix(prefix, path)) return path;
    return std.fs.path.join(allocator, &.{ prefix, path });
}

fn strippedPath(prefix: []const u8, path: []const u8) []const u8 {
    if (!hasPathPrefix(prefix, path)) return path;
    if (path.len == prefix.len) return path[path.len..];
    return path[prefix.len + 1 ..];
}

fn hasPathPrefix(prefix: []const u8, path: []const u8) bool {
    if (prefix.len == 0 or !std.mem.startsWith(u8, path, prefix)) return false;
    return path.len == prefix.len or path[prefix.len] == '/';
}

test "dependency paths may include or omit their prefix" {
    const added = try prefixedPath(std.testing.allocator, "desk", "mar/example.hoon");
    defer std.testing.allocator.free(added);

    try std.testing.expectEqualStrings("desk/mar/example.hoon", added);
    try std.testing.expectEqualStrings("desk/mar/example.hoon", try prefixedPath(std.testing.allocator, "desk", "desk/mar/example.hoon"));
    try std.testing.expectEqualStrings("mar/example.hoon", strippedPath("desk", "desk/mar/example.hoon"));
    try std.testing.expectEqualStrings("mar/example.hoon", strippedPath("desk", "mar/example.hoon"));
    try std.testing.expectEqualStrings("desk-tools/example.hoon", strippedPath("desk", "desk-tools/example.hoon"));
}

fn expandHomePath(allocator: std.mem.Allocator, step: *std.Build.Step, path: []const u8) ![]const u8 {
    if (std.mem.eql(u8, path, "~")) {
        return std.process.getEnvVarOwned(allocator, "HOME") catch |err| {
            return step.fail("could not expand '~': HOME is unavailable: {s}", .{@errorName(err)});
        };
    }

    if (std.mem.startsWith(u8, path, "~/")) {
        const home = std.process.getEnvVarOwned(allocator, "HOME") catch |err| {
            return step.fail("could not expand '~': HOME is unavailable: {s}", .{@errorName(err)});
        };
        return std.fs.path.join(allocator, &.{ home, path[2..] });
    }

    return path;
}

fn copyDistToTarget(allocator: std.mem.Allocator, step: *std.Build.Step, target_path: []const u8) !void {
    if (!pathExists("dist")) {
        return step.fail("dist directory not found. Run build first", .{});
    }
    if (!pathExists(target_path)) {
        return step.fail("target path '{s}' does not exist", .{target_path});
    }

    std.debug.print("Clearing destination desk...\n", .{});
    try clearDirContents(allocator, target_path);

    std.debug.print("Copying /dist to destination desk...\n", .{});
    try copyDirContents(allocator, "dist", target_path);

    std.debug.print("Copied!\n", .{});
}

fn copyDirContents(allocator: std.mem.Allocator, source_path: []const u8, dest_path: []const u8) !void {
    var source_dir = try std.fs.cwd().openDir(source_path, .{ .iterate = true });
    defer source_dir.close();

    try std.fs.cwd().makePath(dest_path);
    var it = source_dir.iterate();
    while (try it.next()) |entry| {
        const src = try std.fs.path.join(allocator, &.{ source_path, entry.name });
        const dst = try std.fs.path.join(allocator, &.{ dest_path, entry.name });

        switch (entry.kind) {
            .directory => try copyDirContents(allocator, src, dst),
            .file => try copyFilePath(src, dst),
            else => {},
        }
    }
}

fn copyFilePath(source_path: []const u8, dest_path: []const u8) !void {
    if (std.fs.path.dirname(dest_path)) |parent| {
        try std.fs.cwd().makePath(parent);
    }
    try std.fs.cwd().copyFile(source_path, std.fs.cwd(), dest_path, .{});
}

fn clearDirContents(allocator: std.mem.Allocator, dir_path: []const u8) !void {
    {
        var dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
        defer dir.close();

        var it = dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .file or entry.kind == .sym_link) {
                const child_path = try std.fs.path.join(allocator, &.{ dir_path, entry.name });
                try std.fs.cwd().deleteFile(child_path);
            }
        }
    }

    {
        var dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
        defer dir.close();

        var it = dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .directory) {
                const child_path = try std.fs.path.join(allocator, &.{ dir_path, entry.name });
                try clearDirContents(allocator, child_path);
                try std.fs.cwd().deleteDir(child_path);
            }
        }
    }
}

fn recreateDir(path: []const u8) !void {
    try deleteTreeIfExists(path);
    try std.fs.cwd().makePath(path);
}

fn deleteTreeIfExists(path: []const u8) !void {
    if (pathExists(path)) {
        try std.fs.cwd().deleteTree(path);
    }
}

fn pathExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}
