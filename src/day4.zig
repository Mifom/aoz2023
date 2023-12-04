const std = @import("std");

fn parseList(alloc: std.mem.Allocator, input: []const u8) std.ArrayList(u16) {
    var numbers = std.ArrayList(u16).init(alloc);
    var num_strs = std.mem.split(u8, input, " ");
    while (num_strs.next()) |str| {
        if (str.len == 0) {
            continue;
        }
        numbers.append(std.fmt.parseInt(u16, str, 10) catch unreachable) catch unreachable;
    }
    return numbers;
}

const Card = struct {
    winning: std.ArrayList(u16),
    my: std.ArrayList(u16),

    fn parse(alloc: std.mem.Allocator, input: []const u8) Card {
        var parts = std.mem.split(u8, input, "|");
        return .{
            .winning = parseList(alloc, parts.next().?),
            .my = parseList(alloc, parts.next().?),
        };
    }

    fn deinit(self: Card) void {
        self.winning.deinit();
        self.my.deinit();
    }

    fn score(self: *const Card) u32 {
        var points: u32 = 0;
        for (self.my.items) |num| {
            for (self.winning.items) |win| {
                if (num == win) {
                    points += 1;
                }
            }
        }
        return points;
    }
};

pub fn part2(alloc: std.mem.Allocator, input: []const u8) u32 {
    var lines = std.mem.split(u8, input, "\n");
    var cardCount = std.ArrayList(u32).init(alloc);
    defer cardCount.deinit();
    var idx: usize = 0;
    while (lines.next()) |line| {
        const colon = std.mem.indexOf(u8, line, ":") orelse continue;
        const card = Card.parse(alloc, line[(colon + 1)..]);
        defer card.deinit();
        const score = card.score();
        const until = idx + score + 1;
        if (cardCount.items.len < until) {
            for (cardCount.items.len..until) |zero_idx| {
                cardCount.insert(zero_idx, 0) catch unreachable;
            }
        }
        cardCount.items[idx] += 1;
        const multiplier = cardCount.items[idx];
        for (idx + 1..(idx + score + 1)) |add_idx| {
            cardCount.items[add_idx] += multiplier;
        }
        idx += 1;
    }
    var sum: u32 = 0;
    for (cardCount.items) |count| {
        sum += count;
    }
    return sum;
}
pub fn part1(alloc: std.mem.Allocator, input: []const u8) u32 {
    var sum: u32 = 0;
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        const colon = std.mem.indexOf(u8, line, ":") orelse continue;
        const card = Card.parse(alloc, line[(colon + 1)..]);
        defer card.deinit();
        const score = card.score();
        if (score != 0) {
            const start: u32 = 1;
            sum += start << @intCast(score - 1);
        }
    }
    return sum;
}

test "Part 1" {
    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    try std.testing.expectEqual(part1(std.testing.allocator, input), 13);
}
test "Part 2" {
    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    try std.testing.expectEqual(part2(std.testing.allocator, input), 30);
}
