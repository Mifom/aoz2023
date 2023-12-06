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

pub fn part1(alloc: mem.Allocator, input: []const u8) u32 {
    var lines = mem.split(u8, input, "\n");
    var timeStr = lines.next().?;
    var times = parseInts(u32, alloc, timeStr[5..]);
    defer times.deinit();
    var distStr = lines.next().?;
    var dists = parseInts(u32, alloc, distStr[9..]);
    defer dists.deinit();
    var mul: u32 = 1;
    for (0..times.items.len) |idx| {
        const time = times.items[idx];
        const dist = dists.items[idx];
        const len = std.math.sqrt(time * time - 4 * dist - 1);
        var multiplier: u32 = undefined;
        if (time % 2 == 0) {
            multiplier = 1 + len / 2 * 2;
        } else {
            multiplier = (len + 1) / 2 * 2;
        }
        mul *= multiplier;
    }
    return mul;
}

test "Part 1" {
    const input =
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;

    try std.testing.expectEqual(part1(std.testing.allocator, input), 288);
}

pub fn part2(alloc: mem.Allocator, input: []const u8) u64 {
    _ = alloc;
    var lines = mem.split(u8, input, "\n");
    var timeLine = lines.next().?[5..];
    var time: u64 = 0;
    for (timeLine) |c| {
        if (c >= '0' and c <= '9') {
            time = time * 10 + (c - '0');
        }
    }

    var distLine = lines.next().?[9..];
    var dist: u64 = 0;
    for (distLine) |c| {
        if (c >= '0' and c <= '9') {
            dist = dist * 10 + (c - '0');
        }
    }

    const len = std.math.sqrt(time * time - 4 * dist - 1);
    var multiplier: u64 = undefined;
    if (time % 2 == 0) {
        multiplier = 1 + len / 2 * 2;
    } else {
        multiplier = (len + 1) / 2 * 2;
    }
    return multiplier;
}
test "Part 2" {
    const input =
        \\Time:      7  15   30
        \\Distance:  9  40  200
    ;

    try std.testing.expectEqual(part2(std.testing.allocator, input), 71503);
}
