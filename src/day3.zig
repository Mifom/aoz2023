const std = @import("std");

const Number = struct { value: u32, row: usize, col: usize, len: usize };

const Symbol = struct {
    row: usize,
    col: usize,
    isGear: bool,
};

const Field = struct {
    numbers: std.ArrayList(Number),
    symbols: std.ArrayList(Symbol),
    fn parse(alloc: std.mem.Allocator, input: []const u8) Field {
        var lines = std.mem.split(u8, input, "\n");
        var numbers = std.ArrayList(Number).init(alloc);
        var symbols = std.ArrayList(Symbol).init(alloc);
        var row: usize = 0;
        while (lines.next()) |line| {
            {
                var pos: usize = 0;
                while (pos < line.len) {
                    const start = std.mem.indexOfNonePos(u8, line, pos, ".") orelse break;

                    if (line[start] >= '0' and line[start] <= '9') {
                        // numbers
                        const end = std.mem.indexOfNonePos(u8, line, start, "1234567890") orelse line.len;
                        pos = end;
                        numbers.append(.{
                            .value = std.fmt.parseInt(u32, line[start..end], 10) catch unreachable,
                            .row = row,
                            .col = start,
                            .len = end - start,
                        }) catch unreachable;
                    } else {
                        // symbols
                        const isGear = line[start] == '*';
                        pos = start + 1;
                        symbols.append(.{
                            .row = row,
                            .col = start,
                            .isGear = isGear,
                        }) catch unreachable;
                    }
                }
            }

            row += 1;
        }
        return .{
            .numbers = numbers,
            .symbols = symbols,
        };
    }

    fn deinit(self: Field) void {
        self.numbers.deinit();
        self.symbols.deinit();
    }
};

fn dist(left: usize, right: usize) usize {
    if (left > right) {
        return left - right;
    } else {
        return right - left;
    }
}

pub fn part1(alloc: std.mem.Allocator, input: []const u8) u32 {
    var sum: u32 = 0;
    const field = Field.parse(alloc, input);
    defer field.deinit();
    for (field.numbers.items) |number| {
        var near_row = false;
        for (field.symbols.items) |symbol| {
            if (dist(symbol.row, number.row) <= 1) {
                near_row = true;
            } else {
                if (near_row) {
                    break;
                } else {
                    continue;
                }
            }
            if (symbol.col + 1 >= number.col and symbol.col <= number.col + number.len) {
                sum += number.value;
                break;
            }
        }
    }
    return sum;
}

pub fn part2(alloc: std.mem.Allocator, input: []const u8) u32 {
    var sum: u32 = 0;
    const field = Field.parse(alloc, input);
    defer field.deinit();
    for (field.symbols.items) |symbol| {
        var ratio: u32 = 1;
        var n: u32 = 0;
        var near_row = false;
        for (field.numbers.items) |number| {
            if (dist(symbol.row, number.row) <= 1) {
                near_row = true;
            } else {
                if (near_row) {
                    break;
                } else {
                    continue;
                }
            }
            if (symbol.col + 1 >= number.col and symbol.col <= number.col + number.len) {
                if (n == 2) {
                    break;
                }
                ratio *= number.value;
                n += 1;
            }
        }
        if (n == 2) {
            sum += ratio;
        }
    }
    return sum;
}

test "Part 1" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;
    try std.testing.expectEqual(part1(std.testing.allocator, input), 4361);
}
test "Part 2" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;
    try std.testing.expectEqual(part2(std.testing.allocator, input), 467835);
}
