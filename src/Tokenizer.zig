const Tokenizer = @This();

const std = @import("std");
const token = @import("token.zig");

/// Unmanaged reference to externally initialized lookup table. Must provide
/// allocator with which to fill lookup table values during parse; values in
/// lookup table *must* be freed separately by caller.
lookup: struct {
    tables: *token.Lookup,
    allocator: std.mem.Allocator,
},

/// Tokenization parsing history. This context is used internally to parse
/// input streams correctly, and should not be used by the caller.
history: struct {
    /// Last parsed token. Used internally to determine if the last parsed
    /// token should be invalidated due to new parsing input.
    token: ?token.Token = null,

    /// Ring buffer of most recently provided inputs. Used to continue parsing
    /// with historical context when input is split across parse invocations.
    buffer: [255]u8 = undefined,
    tail: u8 = 0,
    size: u8 = 0,
} = .{},

test {}
