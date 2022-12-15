const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");

const Item = u128;

const Op = enum {
    Add,
    Mul,
};

const Operation = struct {
    lhs: ?Item,
    rhs: ?Item,
    op: Op,

    pub fn format(value: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) std.os.WriteError!void {
        if (value.lhs) |n| {
            try writer.print("{d} ", .{n});
        } else {
            try writer.print("old ", .{});
        }
        switch (value.op) {
            Op.Add => try writer.print("+ ", .{}),
            Op.Mul => try writer.print("* ", .{}),
        }
        if (value.rhs) |n| {
            return writer.print("{d}", .{n});
        } else {
            return writer.print("old", .{});
        }
    }

    pub fn apply(self: @This(), item: Item) Item {
        return switch(self.op) {
            Op.Add => return (self.lhs orelse item) + (self.rhs orelse item),
            Op.Mul => return (self.lhs orelse item) * (self.rhs orelse item),
        };
    }
};

const Monkey = struct {
    num: usize,
    items: List(Item),
    operation: Operation,
    test_div: usize,
    test_true: usize,
    test_false: usize,
    inspections: usize,

    const Self = @This();

    pub fn format(value: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) std.os.WriteError!void {
        try writer.print("Monkey {d}:\n  Items: ", .{ value.num});

        var i:usize = 0;
        while (i < value.items.items.len) : (i += 1) {
            if (i > 0) {
                try writer.print(", ", .{});
            }
            try writer.print("{d}", .{ value.items.items[i] });
        }

        try writer.print("\n  Operation: new = {s}", .{value.operation});
        try writer.print("\n  Test: divisible by {d}", .{value.test_div});
        try writer.print("\n    If true: throw to monkey {d}", .{value.test_true});
        return writer.print("\n    If false: throw to monkey {d}\n", .{value.test_false});
    }

    pub fn throw(self: *Self, monkeys: *List(Monkey)) !void {
        print("Monkey {}:", .{self.num});
        if (self.items.items.len == 0) {
            print("  No items left to throw!\n", .{});
            return;
        }

        for (self.items.items) |item| {
            self.inspections += 1;
            print("  Monkey inspects an item with a worry level of {}.\n", .{item});

            var new_item = self.operation.apply(item);
            print("    Monkey applies '{}' to the item, resulting in a worry level of {}.\n", .{self.operation, new_item});
            new_item = @divFloor(new_item, 3);
            print("    Monkey gets bored with item. Worry level is divided by 3 to {}.\n", .{new_item});
            if (@rem(new_item, self.test_div) == 0) {
                print("    Current item is divisible by {}.\n", .{self.test_div});
                print("    Monkey throws item to monkey {}.\n", .{self.test_true});
                try monkeys.items[self.test_true].items.append(new_item);
            } else {
                print("    Current item is not divisible by {}.\n", .{self.test_div});
                print("    Monkey throws item to monkey {}.\n", .{self.test_true});
                try monkeys.items[self.test_false].items.append(new_item);
            }
        }
        self.items.clearAndFree();
    }
};

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var monkeys = List(Monkey).init(gpa);
    defer monkeys.deinit();


    var cur_monkey: ?*Monkey = null;
    while (splits.next()) |line| {
        if (eql(u8, line, "")) {
            continue;
        }

        if (startsWith(u8, line, "Monkey ")) {
            const monkey_num = line[7]-'0';
            try monkeys.append(Monkey{
                .num = monkey_num,
                .items = List(Item).init(gpa),
                .operation = Operation{
                    .lhs = undefined,
                    .rhs = undefined,
                    .op = undefined,
                },
                .test_div = undefined,
                .test_true = undefined,
                .test_false = undefined,
                .inspections = 0,
            });
            cur_monkey = &(monkeys.items[monkey_num]);
        } else if (startsWith(u8, line, "  Starting items: ")) {
            var items = split(u8, line[18..], ", ");
            while (items.next()) |item| {
                try cur_monkey.?.items.append(try parseInt(Item, item, 10));
            }
        } else if (startsWith(u8, line, "  Operation: new = ")) {
            var tokens = tokenize(u8, line[19..], " ");
            const lhs = tokens.next() orelse unreachable;
            const op = tokens.next() orelse unreachable;
            const rhs = tokens.next() orelse unreachable;

            if (lhs[0] == 'o') {
                cur_monkey.?.operation.lhs = null;
            } else {
                cur_monkey.?.operation.lhs = try parseInt(Item, lhs, 10);
            }

            cur_monkey.?.operation.op = switch(op[0]) {
                '+' => Op.Add,
                '*' => Op.Mul,
                else => unreachable,
            };

            if (rhs[0] == 'o') {
                cur_monkey.?.operation.rhs = null;
            } else {
                cur_monkey.?.operation.rhs = try parseInt(Item, rhs, 10);
            }
        } else if (startsWith(u8, line, "  Test: divisible by ")) {
            cur_monkey.?.test_div = try parseInt(u8, line[21..], 10);
        } else if (startsWith(u8, line, "    If true: throw to monkey ")) {
            cur_monkey.?.test_true = line[29] - '0';
        } else if (startsWith(u8, line, "    If false: throw to monkey ")) {
            cur_monkey.?.test_false = line[30] - '0';
        } else {
            continue;
        }
    }

    print("Inital state:\n", .{});
    for (monkeys.items) |*monkey| {
        print("{}\n", .{monkey});
    }

    print("\n", .{});

    var round:usize = 0;
    while(round < 20) : (round += 1) {
        for (monkeys.items) |*monkey| {
            try monkey.throw(&monkeys);
        }

        print("After Round {d}:\n\n", .{round+1});
        for (monkeys.items) |*monkey| {
            print("{}\n", .{monkey});
        }

        print("\n", .{});
    }

    sort(Monkey, monkeys.items, void{}, inspectionOrder);

    for (monkeys.items) |*monkey| {
        print(">> Monkey {d} inspected {d} times\n", .{monkey.num, monkey.inspections});
    }

    print("\nMonkey business: {d}", .{monkeys.items[0].inspections * monkeys.items[1].inspections});
}

fn inspectionOrder(ctx: void, lhs: Monkey, rhs: Monkey) bool {
    _ = ctx;
    return rhs.inspections < lhs.inspections;
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
const eql = std.mem.eql;
const startsWith = std.mem.startsWith;

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
