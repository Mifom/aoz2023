const std = @import("std");

const Cubes = struct {
    red: u32,
    green: u32,
    blue: u32,
};

fn getCubesForGame(input: []const u8) Cubes {
    var cubes: Cubes = .{ .red = 0, .green = 0, .blue = 0 };
    var iter = std.mem.splitAny(u8, input, ",;");
    while (iter.next()) |cubes_input| {
        var cubes_iter = std.mem.splitScalar(u8, cubes_input, ' ');
        _ = cubes_iter.next();
        const value = std.fmt.parseInt(u32, cubes_iter.next().?, 10) catch unreachable;
        const name = cubes_iter.next().?;
        if (std.mem.eql(u8, name, "red") and cubes.red < value) {
            cubes.red = value;
        }
        if (std.mem.eql(u8, name, "green") and cubes.green < value) {
            cubes.green = value;
        }
        if (std.mem.eql(u8, name, "blue") and cubes.blue < value) {
            cubes.blue = value;
        }
    }
    return cubes;
}

pub fn part1(input: []const u8) u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        const colon = std.mem.indexOf(u8, line, ":") orelse continue;
        const gameNum = std.fmt.parseInt(u8, line[5..colon], 10) catch unreachable;
        const cubes = getCubesForGame(line[(colon + 1)..]);
        if (cubes.red <= 12 and cubes.green <= 13 and cubes.blue <= 14) {
            sum += gameNum;
        }
    }
    return sum;
}

pub fn part2(input: []const u8) u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        const colon = std.mem.indexOf(u8, line, ":") orelse continue;
        const cubes = getCubesForGame(line[(colon + 1)..]);
        sum += cubes.red * cubes.green * cubes.blue;
    }
    return sum;
}

test "Part 1" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    try std.testing.expectEqual(part1(input), 8);
}

test "Part 2" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    try std.testing.expectEqual(part2(input), 2286);
}
