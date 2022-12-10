const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");

const Tree = struct {
    height: u8,
    visible: bool,
};

const TreeList = List(Tree);

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var grid = List(TreeList).init(gpa);
    defer grid.deinit();

    // Step one, build the grid
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        var tl = TreeList.init(gpa);
        for (line) |c| {
            try tl.append(Tree{
                .height = c - '0',
                .visible = false, // top line is always visible
            });
        }
        try grid.append(tl);
    }
    const height = grid.items.len;
    const width = grid.items[0].items.len;

    // Set top and bottom lines to visible
    for (grid.items[0].items) |*tree| {
        tree.visible = true;
    }
    for (grid.items[grid.items.len-1].items) |*tree| {
        tree.visible = true;
    }

    // start start and end of all lines to visible
    for (grid.items) |*row| {
        row.items[0].visible = true;
        row.items[row.items.len-1].visible = true;
    }

    // output grid for debug
    for (grid.items) |*row| {
        for (row.items) |*tree| {
            if (tree.visible) {
                print("{}", .{tree.height});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    print("\n", .{});

    // Step two, set tree visibility horizontally
    for (grid.items) |*row| {
        var lastTallestTree: ?*Tree = null;
        for (row.items) |*tree| {
            if (lastTallestTree) |lt| {
                if (tree.height > lt.height) {
                    lastTallestTree = tree;
                    tree.visible = true;
                }
            } else {
                tree.visible = true;
                lastTallestTree = tree;
            }
        }

        var i = row.items.len;
        lastTallestTree = null;
        while (i > 0) : (i -= 1) {
            var tree = &(row.items[i-1]);
            if (lastTallestTree) |lt| {
                if (tree.height > lt.height) {
                    lastTallestTree = tree;
                    tree.visible = true;
                }
            } else {
                tree.visible = true;
                lastTallestTree = tree;
            }
        }
    }

    // output grid for debug
    for (grid.items) |row| {
        for (row.items) |tree| {
            if (tree.visible) {
                print("{}", .{tree.height});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    print("\n", .{});

    // Step three, set tree visibility vertically
    var x:usize = 0;
    while (x < width-1) : (x += 1) {
        var lastTallestTree: ?*Tree = null;
        for (grid.items) |*row| {
            var tree = &(row.items[x]);
            if (lastTallestTree) |lt| {
                if (tree.height > lt.height) {
                    lastTallestTree = tree;
                    tree.visible = true;
                }
            } else {
                tree.visible = true;
                lastTallestTree = tree;
            }
        }
    }

    x = 0;
    while (x < width-1) : (x += 1) {
        var y:usize = height - 1;
        var lastTallestTree: ?*Tree = null;
        while (y > 0) : (y -= 1) {
            var row = &(grid.items[y]);
            var tree = &(row.items[x]);
            if (lastTallestTree) |lt| {
                if (tree.height > lt.height) {
                    lastTallestTree = tree;
                    tree.visible = true;
                }
            } else {
                tree.visible = true;
                lastTallestTree = tree;
            }
        }
    }

    // Output final tree visibility
    var visible:usize = 0;
    var hidden:usize = 0;
    for (grid.items) |row| {
        for (row.items) |tree| {
            if (tree.visible) {
                visible += 1;
                print("{}", .{tree.height});
            } else {
                hidden += 1;
                print(".", .{});
            }
        }
        print("\n", .{});
    }
    print("Visible: {}, Hidden: {}\n", .{visible, hidden});
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
