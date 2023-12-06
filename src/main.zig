const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");

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
        const start1 = std.time.microTimestamp();
        const results1 = day1.part1(input);
        const end1 = std.time.microTimestamp();
        try stdout.print("Part 1({} microseconds): {}\n", .{ end1 - start1, results1 });
        const start2 = std.time.microTimestamp();
        const results2 = day1.part2(input);
        const end2 = std.time.microTimestamp();
        try stdout.print("Part 2({} microseconds): {}\n", .{ end2 - start2, results2 });
    }
    {
        try stdout.print("Day 2:\n", .{});
        const input = try readInput(alloc, "test/2");
        const start1 = std.time.microTimestamp();
        const results1 = day2.part1(input);
        const end1 = std.time.microTimestamp();
        try stdout.print("Part 1({} microseconds): {}\n", .{ end1 - start1, results1 });
        const start2 = std.time.microTimestamp();
        const results2 = day2.part2(input);
        const end2 = std.time.microTimestamp();
        try stdout.print("Part 2({} microseconds): {}\n", .{ end2 - start2, results2 });
    }
    {
        try stdout.print("Day 3:\n", .{});
        const input = try readInput(alloc, "test/3");
        const start1 = std.time.microTimestamp();
        const results1 = day3.part1(alloc, input);
        const end1 = std.time.microTimestamp();
        try stdout.print("Part 1({} microseconds): {}\n", .{ end1 - start1, results1 });
        const start2 = std.time.microTimestamp();
        const results2 = day3.part2(alloc, input);
        const end2 = std.time.microTimestamp();
        try stdout.print("Part 2({} microseconds): {}\n", .{ end2 - start2, results2 });
    }
    {
        try stdout.print("Day 4:\n", .{});
        const input = try readInput(alloc, "test/4");
        const start1 = std.time.microTimestamp();
        const results1 = day4.part1(alloc, input);
        const end1 = std.time.microTimestamp();
        try stdout.print("Part 1({} microseconds): {}\n", .{ end1 - start1, results1 });
        const start2 = std.time.microTimestamp();
        const results2 = day4.part2(alloc, input);
        const end2 = std.time.microTimestamp();
        try stdout.print("Part 2({} microseconds): {}\n", .{ end2 - start2, results2 });
    }
    {
        try stdout.print("Day 5:\n", .{});
        const input = try readInput(alloc, "test/5");
        const start1 = std.time.microTimestamp();
        const results1 = day5.part1(alloc, input);
        const end1 = std.time.microTimestamp();
        try stdout.print("Part 1({} microseconds): {}\n", .{ end1 - start1, results1 });
        const start2 = std.time.microTimestamp();
        const results2 = day5.part2(alloc, input);
        const end2 = std.time.microTimestamp();
        try stdout.print("Part 2({} microseconds): {}\n", .{ end2 - start2, results2 });
    }
    {
        try stdout.print("Day 6:\n", .{});
        const input = try readInput(alloc, "test/6");
        const start1 = std.time.microTimestamp();
        const results1 = day6.part1(alloc, input);
        const end1 = std.time.microTimestamp();
        try stdout.print("Part 1({} microseconds): {}\n", .{ end1 - start1, results1 });
        const start2 = std.time.microTimestamp();
        const results2 = day6.part2(alloc, input);
        const end2 = std.time.microTimestamp();
        try stdout.print("Part 2({} microseconds): {}\n", .{ end2 - start2, results2 });
    }
}
