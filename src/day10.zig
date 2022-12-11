const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");

pub fn main() !void {
    var cycles = List(?i64).init(gpa);
    defer cycles.deinit();

    var splits = split(u8, data, "\n");
    var i: usize = 0;
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        const op = line[0];
        var num:i64 = 0;

        switch (op) {
            'n' => {
                i = i + 1;
                print("noop\n", .{});
            },
            'a' => {
                num = try parseInt(i64, line[5..], 10);
                i = i + 2;
                print("addx {}\n", .{num});
            },
            else => unreachable,
        }
        while (cycles.items.len < i+1) {
            try cycles.append(null);
        }
        cycles.items[i] = num;
    }

    var x:i64 = 1;
    var signal_sum:i64 = 0;
    const sprite = [_]u8{'.'} ** 40;
    for (cycles.items) |val, idx| {
        if (val) |c| {
            x += c;
        }

        var line = sprite;
        if (x >= -1 and x <= 40) {
            if (x == -1) {
                line[0] = '#';
            } else if (x == 40) {
                line[39] = '#';
            } else {
                const offset = @intCast(usize, x);
                line[offset] = '#';
                if (offset > 0) {
                    line[offset-1] = '#';
                }
                if (offset < 39) {
                    line[offset+1] = '#';
                }
            }
        }

        var cycle:i64 = @intCast(i64, idx)+1;
        switch (cycle) {
            20,60,100,140,180,220 => {
                signal_sum += (cycle * x);
            },
            1,41,81,121,161,201  => |v| {
                print("cycle {0d: >4}->", .{v});
            },
            40,80,120,160,200,240 => |v| {
                print("<-cycle {}\n", .{v});
            },
            else => {
                print("{c}", .{line[@intCast(usize, @mod(cycle-1, 40))]});
            },
        }
    }
    print("signal sum: {}\n", .{signal_sum});
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
