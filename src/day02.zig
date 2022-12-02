const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

const Move = enum(u32) {
    Rock = 1,
    Paper = 2,
    Scissors = 3,
};

const Result = enum(u32) {
    Win = 6,
    Draw = 3,
    Lose = 0,
};

pub fn main() !void {
    var p1score: u32 = 0;
    var p2score: u32 = 0;
    var splits = split(u8, data, "\n");
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        const oMove = switch (line[0]) {
            'A' => Move.Rock,
            'B' => Move.Paper,
            'C' => Move.Scissors,
            else => unreachable,
        };
        const pMove = switch (line[2]) {
            'X' => Move.Rock,
            'Y' => Move.Paper,
            'Z' => Move.Scissors,
            else => unreachable,
        };
        const pResult = switch (line[2]) {
            'X' => Result.Lose,
            'Y' => Result.Draw,
            'Z' => Result.Win,
            else => unreachable,
        };

        p1score += @enumToInt(pMove);
        if (oMove == pMove) {
            p1score += @enumToInt(Result.Draw);
        } else if (oMove == Move.Rock and pMove == Move.Scissors) {
            p1score += @enumToInt(Result.Lose);
        } else if (oMove == Move.Paper and pMove == Move.Rock) {
            p1score += @enumToInt(Result.Lose);
        } else if (oMove == Move.Scissors and pMove == Move.Paper) {
            p1score += @enumToInt(Result.Lose);
        } else {
            p1score += @enumToInt(Result.Win);
        }

        p2score += @enumToInt(pResult);
        switch (oMove) {
            Move.Rock => switch (pResult) {
                Result.Win => p2score += @enumToInt(Move.Paper),
                Result.Draw => p2score += @enumToInt(Move.Rock),
                Result.Lose => p2score += @enumToInt(Move.Scissors),
            },
            Move.Paper => switch (pResult) {
                Result.Win => p2score += @enumToInt(Move.Scissors),
                Result.Draw => p2score += @enumToInt(Move.Paper),
                Result.Lose => p2score += @enumToInt(Move.Rock),
            },
            Move.Scissors => switch (pResult) {
                Result.Win => p2score += @enumToInt(Move.Rock),
                Result.Draw => p2score += @enumToInt(Move.Scissors),
                Result.Lose => p2score += @enumToInt(Move.Paper),
            },
        }
    }
    print("Part 1: {d}\n", .{p1score});
    print("Part 2: {d}\n", .{p2score});
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
