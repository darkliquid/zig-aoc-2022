const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const io = @import("io");
const Reader = io.Reader;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

fn run(part2: bool) !void {
    var splits = split(u8, data, "\n");
    var stack_lines = List([]const u8).init(gpa);
    defer stack_lines.deinit();
    var max_stack_line: u8 = 0;

    // Step one, parse the stack definitions
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        // Get the total number of stacks and buffer the stack lines for later
        if (line.len >= 2 and line[1] == '1') {
            var cols = tokenize(u8, line, " ");
            while(true) {
                _ = cols.next() orelse break;
                max_stack_line +=1;
            }
        } else {
            try stack_lines.append(line);
        }
    }

    var stacks = List(List(u8)).init(gpa);
    defer stacks.deinit();

    while(max_stack_line>0) {
        try stacks.append(List(u8).init(gpa));
        max_stack_line -= 1;
    }

    for (stack_lines.items) |line| {
        var idx:u8 = 0;
        while (idx*4 < line.len-1) {
            var char = line[(idx*4)+1];
            if (char != ' ') {
                try stacks.items[idx].insert(0, char);
            }
            idx += 1;
        }
    }

    for (stacks.items) |stack| {
        print("stack: {s}\n", .{stack.items});
    }

    // Step two, parse the moves
    while(splits.next()) |line| {
        var t = tokenize(u8, line, " ");
        _ = t.next() orelse break;
        var amount = try parseInt(u8, t.next() orelse "0", 10);
        _ = t.next() orelse break;
        var from = try parseInt(u8, t.next() orelse "0", 10);
        _ = t.next() orelse break;
        var to = try parseInt(u8, t.next() orelse "0", 10);

        if (part2) {
            var tmp = List(u8).init(gpa);
            defer tmp.deinit();
            while(amount > 0) {
                try tmp.insert(0, stacks.items[from-1].pop());
                amount -= 1;
            }
            try stacks.items[to-1].appendSlice(tmp.items);
        } else {
            while(amount > 0) {
                var item = stacks.items[from-1].pop();
                try stacks.items[to-1].append(item);
                amount -= 1;
            }
        }
    }

    for (stacks.items) |stack| {
        print("stack: {s}\n", .{stack.items});
    }

    if (part2) {
        print("part2: \n", .{});
    } else {
        print("part1: \n", .{});
    }
    print("top items: ", .{});
    for (stacks.items) |stack| {
        print("{c}", .{stack.items[stack.items.len-1]});
    }
    print("\n", .{});
}

pub fn main() !void {
    try run(false);
    try run(true);
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
