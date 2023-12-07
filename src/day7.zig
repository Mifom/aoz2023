const std = @import("std");
const mem = std.mem;

const cardList = "23456789TJQKA";
const jokerPos = mem.indexOf(u8, cardList, "J").?;

fn cardPower(card: u8) usize {
    return mem.indexOf(u8, cardList, &[_]u8{card}).?;
}

const HandType = enum { High, Pair, TwoPairs, Three, FullHouse, Four, Five };

const Hand = struct {
    powers: [5]usize,
    ty: HandType,
    bid: u32,

    fn create(alloc: mem.Allocator, input: []const u8, comptime jokered: bool) Hand {
        var parts = mem.split(u8, input, " ");
        const cards = parts.next().?;
        const bid = std.fmt.parseInt(u32, parts.next().?, 10) catch unreachable;

        var map = std.AutoHashMap(u8, u8).init(alloc);
        defer map.deinit();
        var powers: [5]usize = undefined;
        var jokers: u8 = 0;
        for (cards, 0..) |card, idx| {
            if (jokered and card == 'J') {
                jokers += 1;
                powers[idx] = 0;
                continue;
            }
            powers[idx] = cardPower(card);
            if (jokered) {
                powers[idx] += 1;
            }
            var entry = map.getOrPut(card) catch unreachable;
            if (entry.found_existing) {
                entry.value_ptr.* += 1;
            } else {
                entry.value_ptr.* = 1;
            }
        }
        if (jokered and jokers > 0) {
            var max_ptr: ?*u8 = null;
            var iter = map.iterator();
            while (iter.next()) |entry| {
                if (max_ptr) |ptr| {
                    if (ptr.* < entry.value_ptr.*) {
                        max_ptr = entry.value_ptr;
                    }
                } else {
                    max_ptr = entry.value_ptr;
                }
            }
            if (max_ptr) |ptr| {
                ptr.* += jokers;
            } else {
                map.put('J', jokers) catch unreachable;
            }
        }
        var iter = map.iterator();

        var hasFive = false;
        var hasFour = false;
        var hasThree = false;
        var twos: u8 = 0;
        while (iter.next()) |entry| {
            switch (entry.value_ptr.*) {
                4 => hasFour = true,
                3 => hasThree = true,
                2 => twos += 1,
                1 => {},
                else => hasFive = true,
            }
        }
        var ty = HandType.High;
        if (hasFive) {
            ty = HandType.Five;
        } else if (hasFour) {
            ty = HandType.Four;
        } else if (hasThree and twos == 1) {
            ty = HandType.FullHouse;
        } else if (hasThree) {
            ty = HandType.Three;
        } else if (twos == 2) {
            ty = HandType.TwoPairs;
        } else if (twos == 1) {
            ty = HandType.Pair;
        }

        return Hand{
            .ty = ty,
            .powers = powers,
            .bid = bid,
        };
    }

    fn cmp(self: *const Hand, other: *const Hand) i2 {
        const sty = @intFromEnum(self.ty);
        const oty = @intFromEnum(other.ty);
        if (sty < oty) {
            return -1;
        }
        if (sty > oty) {
            return 1;
        }
        for (self.powers, other.powers) |sp, op| {
            if (sp < op) {
                return -1;
            }
            if (sp > op) {
                return 1;
            }
        }
        return 0;
    }
};

fn insertHand(hands: *std.ArrayList(Hand), hand: Hand) !void {
    var left: usize = 0;
    var right = hands.items.len;
    while (left != right) {
        const pos = (left + right) / 2;
        switch (hand.cmp(&hands.items[pos])) {
            -1 => right = pos,
            else => left = pos + 1,
        }
    }
    try hands.insert(left, hand);
}

pub fn part1(alloc: mem.Allocator, input: []const u8) usize {
    var lines = mem.split(u8, input, "\n");
    var hands = std.ArrayList(Hand).init(alloc);
    defer hands.deinit();
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const hand = Hand.create(alloc, line, false);
        insertHand(&hands, hand) catch unreachable;
    }
    var sum: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        sum += hand.bid * rank;
    }

    return sum;
}

test "Part 1" {
    const input =
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ;
    try std.testing.expectEqual(part1(std.testing.allocator, input), 6440);
}

pub fn part2(alloc: mem.Allocator, input: []const u8) usize {
    var lines = mem.split(u8, input, "\n");
    var hands = std.ArrayList(Hand).init(alloc);
    defer hands.deinit();
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const hand = Hand.create(alloc, line, true);
        insertHand(&hands, hand) catch unreachable;
    }
    var sum: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        sum += hand.bid * rank;
    }

    return sum;
}

test "Part 2" {
    const input =
        \\32T3K 765
        \\T55J5 684
        \\KK677 28
        \\KTJJT 220
        \\QQQJA 483
    ;
    try std.testing.expectEqual(part2(std.testing.allocator, input), 5905);
}
