const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var l = List(u8).init(gpa);
    const line = splits.next() orelse "";

    // packet header
    var idx: usize = 0;
    for (line) |c, i| {
        try l.insert(0, c);
        if (l.items.len > 4) {
            _ = l.pop();
            var m = Map(u8, void).init(gpa);
            for (l.items) |x| {
                try m.put(x, {});
            }
            if (m.count() == 4) {
                idx = i+1;
                print("Packet marker at index: {d}\n", .{idx});
                break;
            }
        }
    }

    l.clearAndFree();

    // message header
    for (line[idx..]) |c, i| {
        try l.insert(0, c);
        if (l.items.len > 14) {
            _ = l.pop();
            var m = Map(u8, void).init(gpa);
            for (l.items) |x| {
                try m.put(x, {});
            }
            if (m.count() == 14) {
                idx += i+1;
                print("Message marker at index: {d}\n", .{idx});
                break;
            }
        }

    }
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
