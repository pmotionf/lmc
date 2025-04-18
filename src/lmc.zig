const std = @import("std");
const build = @import("build.zig.zon");

pub const version = std.SemanticVersion.parse(build.version) catch unreachable;

pub const token = @import("token.zig");
pub const Tokenizer = @import("Tokenizer.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}
