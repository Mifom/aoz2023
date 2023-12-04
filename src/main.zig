const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");

fn readInput(alloc: std.mem.Allocator, name: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(name, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    const input = try in_stream.readAllAlloc(alloc, 1_000_000_000);
    return input;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const stdout = std.io.getStdOut().writer();
    {
        try stdout.print("Day 1:\n", .{});
        const input = try readInput(alloc, "test/1");
        const results1 = day1.part1(input);
        try stdout.print("Part 1: {}\n", .{results1});
        const results2 = day1.part2(input);
        try stdout.print("Part 2: {}\n", .{results2});
    }
    {
        try stdout.print("Day 2:\n", .{});
        const input = try readInput(alloc, "test/2");
        const results1 = day2.part1(input);
        try stdout.print("Part 1: {}\n", .{results1});
        const results2 = day2.part2(input);
        try stdout.print("Part 2: {}\n", .{results2});
    }
    {
        try stdout.print("Day 3:\n", .{});
        const input = try readInput(alloc, "test/3");
        const results1 = day3.part1(alloc, input);
        try stdout.print("Part 1: {}\n", .{results1});
        const results2 = day3.part2(alloc, input);
        try stdout.print("Part 2: {}\n", .{results2});
    }
    {
        try stdout.print("Day 4:\n", .{});
        const input = try readInput(alloc, "test/4");
        const results1 = day4.part1(alloc, input);
        try stdout.print("Part 1: {}\n", .{results1});
        const results2 = day4.part2(alloc, input);
        try stdout.print("Part 2: {}\n", .{results2});
    }
}
