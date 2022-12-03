const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

fn priority(char: u8) u8 {
    return switch (char) {
        inline 'a'...'z' => char-96,
        inline 'A'...'Z' => char-38,
        else => unreachable,
    };
}

fn part1() !void {
    var splits = split(u8, data, "\n");
    var total: u32 = 0;
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        const len = line.len;
        const left = line[0..len/2];
        const right = line[len/2..len];

        var map = Map(u8, void).init(gpa);
        defer map.deinit();

        for (left) |c| {
            try map.put(c, {});
        }
        var char:u8 = 0;
        for (right) |c| {
            if (map.contains(c)) {
                char = c;
                break;
            }
        }


        total += priority(char);
    }
    print("part 1: {d}\n", .{total});
}

fn part2() !void {
    var splits = split(u8, data, "\n");
    var total: u32 = 0;
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var line2 = splits.next() orelse "";
        var line3 = splits.next() orelse "";

        var map = Map(u8, bool).init(gpa);
        defer map.deinit();

        for (line) |c| {
            try map.put(c, false);
        }

        for (line2) |c| {
            if (map.contains(c)) {
                try map.put(c, true);
            }
        }

        var char:u8 = 0;
        for (line3) |c| {
            if (map.get(c) orelse false) {
                char = c;
                break;
            }
        }

        total += priority(char);
    }
    print("part 2: {d}\n", .{total});
}

pub fn main() !void {
    try part1();
    try part2();
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
