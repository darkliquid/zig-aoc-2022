const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");

const NodeKind = enum {
    Dir,
    File,
};

const Node = struct {
    name: []const u8,
    size: u32,
    kind: NodeKind,
    children: StrMap(Node),
    parent: ?*Node,
};

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var root = Node{
        .name = "",
        .size = 0,
        .kind = NodeKind.Dir,
        .children = StrMap(Node).init(gpa),
        .parent = null,
    };

    var current_node: *Node = &root;
    while (splits.next()) |line| {
        if (std.mem.eql(u8, line, "")) continue;
        if (line[0] == '$') {
            // this is a command
            if (std.mem.eql(u8, line, "$ ls")) {
                continue;
            } else if (std.mem.eql(u8, line, "$ cd ..")) {
                current_node = current_node.parent.?;
            } else if (std.mem.eql(u8, line, "$ cd /")) {
                current_node = &root;
            } else {
                // cd into a directory
                current_node = current_node.children.getPtr(line[5..]).?;
            }
            continue;
        } else if (std.mem.eql(u8, line[0..4], "dir ")) {
            // add dir to the current nodes child map
            try current_node.children.put(line[4..], Node{
                .name = line[4..],
                .size = 0,
                .kind = NodeKind.Dir,
                .children = StrMap(Node).init(gpa),
                .parent = current_node,
            });
        } else {
            // add file to the current nodes child map
            const space = indexOf(u8, line, ' ').?;
            const size = try parseInt(u32, line[0..space], 10);

            try current_node.children.put(line[space+1..], Node{
                .name = line[space+1..],
                .size = size,
                .kind = NodeKind.File,
                .children = StrMap(Node).init(gpa),
                .parent = current_node,
            });
            var node = current_node;
            while(node.parent) |parent| {
                node.size += size;
                node = parent;
            }
            root.size += size;
        }
    }

    // To begin, find all of the directories with a total size of at most 100000,
    // then calculate the sum of their total sizes. In the example above, these directories
    // are a and e; the sum of their total sizes is 95437 (94853 + 584). (As in this example,
    // this process can count files more than once!)

    // Find all of the directories with a total size of at most 100000. What is the sum of the
    // total sizes of those directories?

    var count = traverse(&root);
    print("count: {d}\n", .{count});

    // Find the smallest directory that, if deleted, would free up enough space on the filesystem
    // (30000000) to run the update. What is the total size of that directory?
    const fsMax:u32 = 70000000;
    const freeSpace = fsMax - root.size;
    const need = 30000000 - freeSpace;
    print("freeSpace: {d}\n", .{freeSpace});
    print("need: {d}\n", .{need});
    count = traverse2(&root, need, 30000000);
    print("count: {d}\n", .{count});
}

fn traverse(n: *Node) u32 {
    var count: u32 = 0;
    if (n.size <= 100000) {
        count += n.size;
    }
    var i = n.children.valueIterator();
    while(i.next()) |node| {
        if (node.kind == NodeKind.Dir) {
            count += traverse(node);
        }
    }
    return count;
}

fn traverse2(n: *Node, target: u32, last: u32) u32 {
    var out: u32 = last;
    if (n.size >= target and n.size <= last) {
        out = n.size;
    }
    var i = n.children.valueIterator();
    while(i.next()) |node| {
        if (node.kind == NodeKind.Dir) {
            var l = traverse2(node, target, out);
            if (l < last) {
                out = l;
            }
        }
    }
    return out;
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
