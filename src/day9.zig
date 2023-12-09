const std = @import("std");
const mem = std.mem;

pub fn parseInts(comptime T: type, alloc: mem.Allocator, input: []const u8) std.ArrayList(T) {
    var result = std.ArrayList(T).init(alloc);
    var intStrs = mem.split(u8, input, " ");
    while (intStrs.next()) |intStr| {
        if (intStr.len == 0) {
            continue;
        }
        result.append(std.fmt.parseInt(T, intStr, 10) catch unreachable) catch unreachable;
    }
    return result;
}

const Extrapolator = struct {
    values: std.ArrayList(std.ArrayList(isize)),

    fn parse(alloc: mem.Allocator, input: []const u8, comptime reversed: bool) Extrapolator {
        var starting = parseInts(isize, alloc, input);
        if (reversed) {
            for (0..starting.items.len / 2) |idx| {
                const moved = starting.items[idx];
                starting.items[idx] = starting.items[starting.items.len - idx - 1];
                starting.items[starting.items.len - idx - 1] = moved;
            }
        }
        var values = std.ArrayList(std.ArrayList(isize)).init(alloc);
        values.append(starting) catch unreachable;
        var equal = false;
        while (!equal) {
            var row = values.getLast();
            var new_row = std.ArrayList(isize).init(alloc);
            var last: ?isize = null;
            var eq: ?isize = null;
            equal = true;

            for (row.items) |right| {
                if (last) |left| {
                    const next = right - left;
                    last = right;
                    if (eq) |e| {
                        if (next != e) {
                            equal = false;
                        }
                    } else {
                        eq = next;
                    }
                    new_row.append(next) catch unreachable;
                } else {
                    last = right;
                }
            }
            values.append(new_row) catch unreachable;
        }
        return Extrapolator{ .values = values };
    }

    fn deinit(self: Extrapolator) void {
        for (self.values.items) |item| {
            item.deinit();
        }
        self.values.deinit();
    }

    fn extrapolate(self: *Extrapolator) isize {
        var values = &self.values.items[self.values.items.len - 1];
        values.append(values.getLast()) catch unreachable;
        var idx = self.values.items.len - 1;
        while (idx > 0) {
            var top = &self.values.items[idx];
            var bottom = &self.values.items[idx - 1];
            bottom.append(bottom.getLast() + top.getLast()) catch unreachable;
            idx -= 1;
        }
        return self.values.items[0].getLast();
    }
};

pub fn part1(alloc: mem.Allocator, input: []const u8) isize {
    var lines = mem.split(u8, input, "\n");
    var sum: isize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var extrapolator = Extrapolator.parse(alloc, line, false);
        defer extrapolator.deinit();
        const res = extrapolator.extrapolate();
        sum += res;
    }
    return sum;
}

pub fn part2(alloc: mem.Allocator, input: []const u8) isize {
    var lines = mem.split(u8, input, "\n");
    var sum: isize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var extrapolator = Extrapolator.parse(alloc, line, true);
        defer extrapolator.deinit();
        const res = extrapolator.extrapolate();
        sum += res;
    }
    return sum;
}

const testInput =
    \\0 3 6 9 12 15
    \\1 3 6 10 15 21
    \\10 13 16 21 30 45
;

test "Test 1" {
    try std.testing.expectEqual(part1(std.testing.allocator, testInput), 114);
}
test "Test 2" {
    try std.testing.expectEqual(part2(std.testing.allocator, testInput), 2);
}
