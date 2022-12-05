const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var count: u32 = 0;
    var count2: u32 = 0;
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var pairs = split(u8, line, ",");
        var a = split(u8, pairs.next() orelse "", "-");
        var b = split(u8, pairs.next() orelse "", "-");

        const a_low = try parseInt(u8, a.next() orelse "", 10);
        const a_high = try parseInt(u8, a.next() orelse "", 10);
        const b_low = try parseInt(u8, b.next() orelse "", 10);
        const b_high = try parseInt(u8, b.next() orelse "", 10);

        if ((a_low >= b_low and a_high <= b_high) or (b_low >= a_low and b_high <= a_high)) {
            count += 1;
        }

        if (
            (a_low <= b_high and a_low >= b_low) or
            (b_low <= a_high and b_low >= a_low)
            ) {
            count2 += 1;
        }
    }
    print("Part 1: {}\n", .{count});
    print("Part 2: {}\n", .{count2});
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
