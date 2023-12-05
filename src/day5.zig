const std = @import("std");
const mem = std.mem;

const MapRange = struct {
    srcStart: u64,
    dstStart: u64,
    len: u64,
};

const Mapper = struct {
    ranges: std.ArrayList(MapRange),

    fn parse(alloc: mem.Allocator, input: []const u8) Mapper {
        var ranges = std.ArrayList(MapRange).init(alloc);
        var lines = mem.split(u8, input, "\n");
        while (lines.next()) |line| {
            var nums = mem.split(u8, line, " ");
            const range = MapRange{
                .dstStart = std.fmt.parseInt(u64, nums.next().?, 10) catch unreachable,
                .srcStart = std.fmt.parseInt(u64, nums.next().?, 10) catch unreachable,
                .len = std.fmt.parseInt(u64, nums.next().?, 10) catch unreachable,
            };
            ranges.append(range) catch unreachable;
        }
        return .{
            .ranges = ranges,
        };
    }

    fn deinit(self: Mapper) void {
        self.ranges.deinit();
    }

    fn map(self: *const Mapper, value: u64) u64 {
        for (self.ranges.items) |range| {
            if (value >= range.srcStart and value < range.srcStart + range.len) {
                return value - range.srcStart + range.dstStart;
            }
        }
        return value;
    }

    fn mapRange(self: *const Mapper, value: SeedRange, results: *std.ArrayList(SeedRange)) void {
        var current = value;
        curr: while (current.len != 0) {
            for (self.ranges.items) |range| {
                if (current.start >= range.srcStart and current.start < range.srcStart + range.len) {
                    var len: u64 = undefined;
                    if (current.start + current.len < range.srcStart + range.len) {
                        len = 0;
                    } else {
                        len =
                            current.start + current.len - range.srcStart - range.len;
                    }
                    results.append(SeedRange{ .start = range.dstStart + current.start - range.srcStart, .len = current.len - len }) catch unreachable;
                    current = SeedRange{ .start = range.srcStart + range.len, .len = len };
                    continue :curr;
                }
            }

            // If not found cut that canbe in range
            const end = current.start + current.len;
            const start =
                for (self.ranges.items) |range|
            {
                if (range.srcStart >= current.start and range.srcStart < end) {
                    break range.srcStart;
                }
            } else blk: {
                break :blk end;
            };

            results.append(SeedRange{ .start = current.start, .len = start - current.start }) catch unreachable;
            current.len = current.start + current.len - start;
            current.start = start;
        }
    }
};

fn testMapper(alloc: mem.Allocator, mapper: *Mapper, range: SeedRange) !void {
    var ranges = std.ArrayList(SeedRange).init(alloc);
    defer ranges.deinit();
    mapper.mapRange(range, &ranges);
    var resultRanges = std.ArrayList(u64).init(alloc);
    defer resultRanges.deinit();
    for (ranges.items) |res_range| {
        const items = res_range.items(alloc);
        defer items.deinit();
        for (items.items) |item| {
            try resultRanges.append(item);
        }
    }
    const items = range.items(alloc);
    defer items.deinit();

    var resultItems = std.ArrayList(u64).init(alloc);
    defer resultItems.deinit();
    for (items.items) |item| {
        try resultItems.append(mapper.map(item));
    }
    for (resultRanges.items) |rangeItem| {
        const found = for (0..resultItems.items.len) |idx| {
            if (rangeItem == resultItems.items[idx]) {
                _ = resultItems.orderedRemove(idx);
                break true;
            }
        } else false;
        if (!found) {
            unreachable;
        }
    }
    if (resultItems.items.len > 0) {
        unreachable;
    }
}

test "Range mapping compare" {
    const alloc = std.testing.allocator;
    var mapper = Mapper.parse(alloc,
        \\100 5 10
        \\5 20 10
    );
    defer mapper.deinit();
    const seed = SeedRange{ .start = 0, .len = 30 };
    try testMapper(alloc, &mapper, seed);
}

pub fn part1(alloc: mem.Allocator, input: []const u8) u64 {
    var seeds = std.ArrayList(u64).init(alloc);
    defer seeds.deinit();
    const seedStart = mem.indexOf(u8, input, ":").?;
    const seedEnd = mem.indexOf(u8, input, "\n").?;
    var seedStrs = mem.split(u8, input[seedStart + 1 .. seedEnd], " ");
    while (seedStrs.next()) |seedStr| {
        if (seedStr.len == 0) {
            continue;
        }
        seeds.append(std.fmt.parseInt(u64, seedStr, 10) catch unreachable) catch unreachable;
    }
    var mappers = std.ArrayList(Mapper).init(alloc);
    defer mappers.deinit();
    defer for (mappers.items) |item| {
        item.deinit();
    };
    var prevEnd = seedEnd;
    while (prevEnd < input.len) {
        const start = mem.indexOfPos(u8, input, prevEnd, ":") orelse break;
        const end = mem.indexOfPos(u8, input, start, "\n\n") orelse input.len;
        mappers.append(Mapper.parse(alloc, input[start + 2 .. end])) catch unreachable;
        prevEnd = end;
    }
    var min: ?u64 = null;
    for (seeds.items) |seed| {
        var value = seed;
        for (mappers.items) |mapper| {
            value = mapper.map(value);
        }
        if (min) |minVal| {
            if (minVal > value) {
                min = value;
            }
        } else {
            min = value;
        }
    }
    return min.?;
}

test "Part 1" {
    const input =
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
    ;

    try std.testing.expectEqual(part1(std.testing.allocator, input), 35);
}

const SeedRange = struct {
    start: u64,
    len: u64,

    fn items(self: *const SeedRange, alloc: mem.Allocator) std.ArrayList(u64) {
        var results = std.ArrayList(u64).init(alloc);
        for (self.start..self.start + self.len) |seed| {
            results.append(seed) catch unreachable;
        }
        return results;
    }
};

pub fn part2(alloc: mem.Allocator, input: []const u8) u64 {
    var seeds = std.ArrayList(SeedRange).init(alloc);
    const seedStart = mem.indexOf(u8, input, ":").?;
    const seedEnd = mem.indexOf(u8, input, "\n").?;
    var seedStrs = mem.split(u8, input[seedStart + 1 .. seedEnd], " ");
    while (true) {
        const seedStartStr = seedStrs.next() orelse break;
        if (seedStartStr.len == 0) {
            continue;
        }
        const seedLenStr = seedStrs.next().?;
        seeds.append(SeedRange{ .start = std.fmt.parseInt(u64, seedStartStr, 10) catch unreachable, .len = std.fmt.parseInt(u64, seedLenStr, 10) catch unreachable }) catch unreachable;
    }
    var mappers = std.ArrayList(Mapper).init(alloc);
    defer mappers.deinit();
    defer for (mappers.items) |item| {
        item.deinit();
    };
    var prevEnd = seedEnd;
    while (prevEnd < input.len) {
        const start = mem.indexOfPos(u8, input, prevEnd, ":") orelse break;
        const end = mem.indexOfPos(u8, input, start, "\n\n") orelse input.len;
        mappers.append(Mapper.parse(alloc, input[start + 2 .. end])) catch unreachable;
        prevEnd = end;
    }
    var results = seeds;
    defer results.deinit();
    for (mappers.items) |mapper| {
        var mapped_results = std.ArrayList(SeedRange).init(alloc);
        for (results.items) |result| {
            mapper.mapRange(result, &mapped_results);
        }
        results.deinit();
        results = mapped_results;
    }

    var min: ?u64 = null;
    for (results.items) |res| {
        if (min) |m| {
            if (m > res.start) {
                min = res.start;
            }
        } else {
            min = res.start;
        }
    }
    return min.?;
}
test "Part 2" {
    const input =
        \\seeds: 79 14 55 13
        \\
        \\seed-to-soil map:
        \\50 98 2
        \\52 50 48
        \\
        \\soil-to-fertilizer map:
        \\0 15 37
        \\37 52 2
        \\39 0 15
        \\
        \\fertilizer-to-water map:
        \\49 53 8
        \\0 11 42
        \\42 0 7
        \\57 7 4
        \\
        \\water-to-light map:
        \\88 18 7
        \\18 25 70
        \\
        \\light-to-temperature map:
        \\45 77 23
        \\81 45 19
        \\68 64 13
        \\
        \\temperature-to-humidity map:
        \\0 69 1
        \\1 0 69
        \\
        \\humidity-to-location map:
        \\60 56 37
        \\56 93 4
    ;

    try std.testing.expectEqual(part2(std.testing.allocator, input), 46);
}
