const std = @import("std");

pub const Keyword = enum {
    true,
    false,
    @"and",
    @"or",
    not,

    @"error",
    print,
};

pub const Operator = enum(u8) {
    // Comparison operators
    @"<" = '<',
    @"=" = '=',
    @">" = '>',
    @"?" = '?',
    @"~" = '~',
    @"<=" = 128,
    @">=" = 129,

    // Math operators
    @"*" = '*',
    @"/" = '/',
    @"%" = '%',
    @"+" = '+',
    @"-" = '-',

    // Assignment operators
    @":" = ':',
};

pub const Pair = enum(u8) {
    @"{" = '{',
    @"}" = '}',
    @"[" = '[',
    @"]" = ']',
    @"(" = '(',
    @")" = ')',
};

pub const Literal = union(enum) {
    number: Number,
    /// Lookup index to string literal.
    string: u32,

    pub const Number = union {
        i: i32,
        u: u32,
        f: f32,
    };
};

pub const Label = union(enum) {
    /// Lookup index of an executable command block label (prefix '$').
    block: u32,
    /// Lookup index of a mutable value label (prefix '@').
    value: u32,
    /// Lookup index of a raw text-replacement label (prefix '&').
    reference: u32,
};

pub const Token = union(enum) {
    newline: void,
    keyword: Keyword,
    operator: Operator,
    pair: Pair,
    literal: Literal,
    label: Label,
};

/// Collection of lookup tables that store dynamically allocated token values.
pub const Lookup = struct {
    label: struct {
        block: struct {
            items: [MAX_LABELS][]u8 = .{&.{}} ** MAX_LABELS,
            size: std.math.IntFittingRange(0, MAX_LABELS) = 0,
        },
        value: struct {
            items: [MAX_LABELS][]u8 = .{&.{}} ** MAX_LABELS,
            size: std.math.IntFittingRange(0, MAX_LABELS) = 0,
        },
        reference: struct {
            items: [MAX_LABELS][]u8 = .{&.{}} ** MAX_LABELS,
            size: std.math.IntFittingRange(0, MAX_LABELS) = 0,
        },
    },

    literal: struct {
        string: struct {
            items: [MAX_LITERALS][]u8 = .{&.{}} ** MAX_LITERALS,
            size: std.math.IntFittingRange(0, MAX_LITERALS) = 0,
        },
    },

    pub const MAX_LABELS = 1023;
    pub const MAX_LITERALS = 2047;

    pub fn deinit(self: *Lookup, alloc: std.mem.Allocator) void {
        for (self.literal.string.items) |string| {
            if (string.len > 0) {
                alloc.free(string);
            }
        }
        self.literal.string.size = 0;

        for (self.label.block.items) |block| {
            if (block.len > 0) {
                alloc.free(block);
            }
        }
        self.label.block.size = 0;

        for (self.label.value.items) |value| {
            if (value.len > 0) {
                alloc.free(value);
            }
        }
        self.label.value.size = 0;

        for (self.label.reference.items) |reference| {
            if (reference.len > 0) {
                alloc.free(reference);
            }
        }
        self.label.reference.size = 0;
    }
};
