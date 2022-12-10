const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

const Coord = struct {
    x: i32,
    y: i32,
};
const Cell = struct {
    head: bool,
    tail: bool,
    head_visits: u8,
    tail_visits: u8,
};

const Result = struct {
    moves: List(Move),
    count: u32,
};

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

const Move = struct {
    dir: Direction,
    dist: u32,
};

fn move_head(moves: List(Move)) !Result {
    var r = Result{
        .moves = List(Move).init(gpa),
        .count = 0,
    };

    var map = Map(Coord, Cell).init(gpa);
    defer map.deinit();

    var last_head = Coord { .x = 0, .y = 0 };
    var last_tail = Coord { .x = 0, .y = 0 };
    try map.put(last_head, Cell { .head = true, .tail = true, .head_visits = 1, .tail_visits = 1 });
    var last_cell = map.getPtr(last_head).?;
    for(moves.items) |move| {
        var dist = move.dist;
        while (dist > 0) {
            dist -= 1;
            last_cell.head = false;
            switch (move.dir) {
                Direction.Right => last_head.x += 1,
                Direction.Left => last_head.x -= 1,
                Direction.Up => last_head.y += 1,
                Direction.Down => last_head.y -= 1,
            }
            if (map.getPtr(last_head)) |cell| {
                cell.head = true;
                cell.tail = false;
                cell.head_visits += 1;
            } else {
                try map.put(last_head, Cell{
                    .head = true,
                    .tail = false,
                    .head_visits = 1,
                    .tail_visits = 0
                });
            }

            if (last_tail.x+2 == last_head.x) {
                r.moves.append(Move{
                    .dir = Direction.Right,
                    .dist = 1,
                }) catch unreachable;
                last_tail.x += 1;
                if (last_tail.y < last_head.y) {
                    r.moves.append(Move{
                        .dir = Direction.Down,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.y += 1;
                } else if (last_tail.y > last_head.y) {
                    r.moves.append(Move{
                        .dir = Direction.Up,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.y -= 1;
                }
            } else if (last_tail.x-2 == last_head.x) {
                r.moves.append(Move{
                    .dir = Direction.Left,
                    .dist = 1,
                }) catch unreachable;
                last_tail.x -= 1;
                if (last_tail.y < last_head.y) {
                    r.moves.append(Move{
                        .dir = Direction.Down,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.y += 1;
                } else if (last_tail.y > last_head.y) {
                    r.moves.append(Move{
                        .dir = Direction.Up,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.y -= 1;
                }
            } else if (last_tail.y+2 == last_head.y) {
                r.moves.append(Move{
                    .dir = Direction.Down,
                    .dist = 1,
                }) catch unreachable;
                last_tail.y += 1;
                if (last_tail.x < last_head.x) {
                    r.moves.append(Move{
                        .dir = Direction.Right,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.x += 1;
                } else if (last_tail.x > last_head.x) {
                    r.moves.append(Move{
                        .dir = Direction.Left,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.x -= 1;
                }
            } else if (last_tail.y-2 == last_head.y) {
                r.moves.append(Move{
                    .dir = Direction.Up,
                    .dist = 1,
                }) catch unreachable;
                last_tail.y -= 1;
                if (last_tail.x < last_head.x) {
                    r.moves.append(Move{
                        .dir = Direction.Right,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.x += 1;
                } else if (last_tail.x > last_head.x) {
                    r.moves.append(Move{
                        .dir = Direction.Left,
                        .dist = 1,
                    }) catch unreachable;
                    last_tail.x -= 1;
                }
            }

            if (map.getPtr(last_tail)) |cell| {
                cell.tail = true;
                cell.tail_visits += 1;
            } else {
                try map.put(last_tail, Cell{
                    .head = false,
                    .tail = true,
                    .head_visits = 0,
                    .tail_visits = 1
                });
            }
            last_cell = map.getPtr(last_head).?;
            print("head: x={d} y={d}\n", .{last_head.x, last_head.y});
            print("tail: x={d} y={d}\n", .{last_tail.x, last_tail.y});
        }
    }

    var it = map.valueIterator();
    while (it.next()) |cell| {
        if (cell.tail_visits > 0) {
            r.count += 1;
        }
    }

    return r;
}

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var moves = List(Move).init(gpa);
    defer moves.deinit();

    while(splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        var dist = try parseInt(u8, line[2..], 10);
        moves.append(Move{
            .dir = switch(line[0]) {
                'R' => Direction.Right,
                'L' => Direction.Left,
                'U' => Direction.Up,
                'D' => Direction.Down,
                else => unreachable,
            },
            .dist = dist
        }) catch unreachable;
    }

    var r:Result = try move_head(moves);
    print("Part 1: {}\n", .{r.count});
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    r = try move_head(r.moves);
    print("Part 2: {}\n", .{r.count});
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
