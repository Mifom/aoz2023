const std = @import("std");
const mem = std.mem;

const Instructions = struct {
    steps: std.ArrayList(bool),
    current: usize,

    fn parse(alloc: mem.Allocator, input: []const u8) Instructions {
        var steps = std.ArrayList(bool).initCapacity(alloc, input.len) catch unreachable;
        for (input) |instruction| {
            switch (instruction) {
                'L' => steps.append(true) catch unreachable,
                'R' => steps.append(false) catch unreachable,
                else => {},
            }
        }
        return Instructions{
            .steps = steps,
            .current = 0,
        };
    }

    fn next(self: *Instructions) bool {
        defer self.current = (self.current + 1) % self.steps.items.len;
        return self.steps.items[self.current];
    }

    fn deinit(self: Instructions) void {
        self.steps.deinit();
    }
};

const Navigation = struct {
    left: []const u8,
    right: []const u8,
};

const Network = struct {
    nodes: std.StringHashMap(Navigation),
    instructions: Instructions,

    fn parse(alloc: mem.Allocator, input: []const u8) Network {
        var lines = mem.split(u8, input, "\n");
        const instructions = Instructions.parse(alloc, lines.next().?);
        var nodes = std.StringHashMap(Navigation).init(alloc);
        while (lines.next()) |line| {
            if (line.len == 0) continue;
            var name_val = mem.split(u8, line, " = ");
            const name = name_val.next().?;
            var val = name_val.next().?;
            var navs = mem.split(u8, val[1 .. val.len - 1], ", ");
            nodes.put(name, Navigation{ .left = navs.next().?, .right = navs.next().? }) catch unreachable;
        }
        return Network{ .nodes = nodes, .instructions = instructions };
    }

    fn deinit(self: *Network) void {
        self.nodes.deinit();
        self.instructions.deinit();
    }

    fn countRoute(self: *Network, start: []const u8) usize {
        var count: usize = 0;
        self.instructions.current = 0;
        var current = start;
        var ran = false;
        while (!ran or !checkOne(current)) {
            ran = true;
            count += 1;
            const entry = self.nodes.get(current).?;
            const goLeft = self.instructions.next();
            if (goLeft) {
                current = entry.left;
            } else {
                current = entry.right;
            }
        }
        return count;
    }

    fn countRoutes(self: *Network, alloc: mem.Allocator) usize {
        var currents = std.ArrayList([]const u8).init(alloc);
        defer currents.deinit();
        var iter = self.nodes.iterator();
        while (iter.next()) |entry| {
            if (entry.key_ptr.*[2] == 'A') {
                currents.append(entry.key_ptr.*) catch unreachable;
            }
        }
        var counters = std.ArrayList(usize).initCapacity(alloc, currents.items.len) catch unreachable;
        defer counters.deinit();
        for (0..currents.items.len) |idx| {
            const res = self.countRoute(currents.items[idx]);
            counters.insert(idx, res) catch unreachable;
        }

        var period: usize = 1;

        for (counters.items) |cycle| {
            period = period / std.math.gcd(period, cycle) * cycle;
        }
        return period;
    }
};

fn checkAll(currents: *std.ArrayList([]const u8)) bool {
    for (currents.items) |current| {
        if (current[current.len - 1] != 'Z') {
            return false;
        }
    }
    return true;
}

fn checkOne(current: []const u8) bool {
    return current[current.len - 1] == 'Z';
}

pub fn part1(alloc: mem.Allocator, input: []const u8) usize {
    var network = Network.parse(alloc, input);
    defer network.deinit();
    return network.countRoute("AAA");
}

test "Part 1.1" {
    const input =
        \\RL
        \\
        \\AAA = (BBB, CCC)
        \\BBB = (DDD, EEE)
        \\CCC = (ZZZ, GGG)
        \\DDD = (DDD, DDD)
        \\EEE = (EEE, EEE)
        \\GGG = (GGG, GGG)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    try std.testing.expectEqual(part1(std.testing.allocator, input), 2);
}

test "Part 1.2" {
    const input =
        \\LLR
        \\
        \\AAA = (BBB, BBB)
        \\BBB = (AAA, ZZZ)
        \\ZZZ = (ZZZ, ZZZ)
    ;
    try std.testing.expectEqual(part1(std.testing.allocator, input), 6);
}

pub fn part2(alloc: mem.Allocator, input: []const u8) usize {
    var network = Network.parse(alloc, input);
    defer network.deinit();
    return network.countRoutes(alloc);
}

test "Part 2" {
    const input =
        \\LR
        \\
        \\11A = (11B, XXX)
        \\11B = (XXX, 11Z)
        \\11Z = (11B, XXX)
        \\22A = (22B, XXX)
        \\22B = (22C, 22C)
        \\22C = (22Z, 22Z)
        \\22Z = (22B, 22B)
        \\XXX = (XXX, XXX)
    ;
    try std.testing.expectEqual(part2(std.testing.allocator, input), 6);
}
