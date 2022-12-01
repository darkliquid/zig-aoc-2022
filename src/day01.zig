const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

const Elf = struct {
    snacks: std.ArrayList(u32),
    total: u32,
};

pub fn compareElf(_: void, a: Elf, b: Elf) bool {
    return a.total < b.total;
}

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var elves = List(Elf).init(gpa);
    var elf = Elf{ .snacks = List(u32).init(gpa), .total = 0 };
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            try elves.append(elf);
            elf = Elf{ .snacks = List(u32).init(gpa), .total = 0  };
            continue;
        }
        const calories = parseInt(u32, line, 10);
        try elf.snacks.append(try calories);
        elf.total += try calories;
    }

    sort(Elf, elves.items, {}, compareElf);
    print("Part 1\n", .{});
    print("{}\n", .{elves.items[elves.items.len-1].total});
    print("Part 2\n", .{});
    const total = elves.items[elves.items.len-1].total + elves.items[elves.items.len-2].total + elves.items[elves.items.len-3].total;
    print("{}\n", .{total});
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
