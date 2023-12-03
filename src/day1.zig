const std = @import("std");

pub fn part1(input: []const u8) u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var first: u8 = 0;
        var last: u8 = 0;
        for (0..(line.len)) |idx| {
            const value = std.fmt.parseInt(u8, line[idx..(idx + 1)], 10) catch continue;
            if (first == 0) {
                first = value;
            }
            last = value;
        }
        sum += first * 10 + last;
    }
    return sum;
}
const names = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn part2(input: []const u8) u32 {
    var sum: usize = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var first: usize = 0;
        var last: usize = 0;
        for (0..(line.len)) |idx| {
            var named_value: ?usize = null;
            for (names, 0..) |name, name_idx| {
                if (idx + name.len > line.len) {
                    continue;
                }
                if (std.mem.eql(u8, line[idx..(idx + name.len)], name)) {
                    named_value = name_idx + 1;
                }
            }
            var value: usize = undefined;
            if (named_value) |v| {
                value = v;
            } else {
                value = std.fmt.parseInt(usize, line[idx..(idx + 1)], 10) catch continue;
            }
            if (first == 0) {
                first = value;
            }
            last = value;
        }
        sum += first * 10 + last;
    }
    return @intCast(sum);
}

test "part 1 example" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;
    try std.testing.expectEqual(part1(input), 142);
}
test "part 2 example" {
    const input =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;
    try std.testing.expectEqual(part2(input), 281);
}
