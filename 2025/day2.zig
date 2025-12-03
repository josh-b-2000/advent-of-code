const std = @import("std");
const data = @embedFile("./day2_input.txt");

const parseInt = std.fmt.parseInt;

pub fn has_repeat(string: []const u8) bool {
    if (string.len < 2) {
        return false;
    }

    if (string.len == 2) {
        return string[0] == string[1];
    }

    const substring_max_length = string.len / 2 + 1;

    for (1..substring_max_length) |len| {
        var iter = std.mem.splitSequence(u8, string, string[0..len]);

        var all_split_empty = true;
        while (iter.next()) |iter_val| {
            if (iter_val.len != 0) {
                all_split_empty = false;
                break;
            }
        }

        if (all_split_empty) return true;
    }
    return false;
}

pub fn main() !void {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const needle = "\n";
    const required_size = std.mem.replacementSize(u8, data, needle, "");

    const sanitised = try allocator.alloc(u8, required_size);
    defer allocator.free(sanitised);

    _ = std.mem.replace(u8, data, needle, "", sanitised);

    var lines = std.mem.tokenizeSequence(u8, sanitised, ",");
    var invalid_count: usize = 0;

    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});

        var range_it = std.mem.tokenizeSequence(u8, line, "-");

        const range_start_str = range_it.next().?;
        const start = try parseInt(usize, range_start_str, 0);

        const range_end_str = range_it.next().?;
        const end = try parseInt(usize, range_end_str, 0);

        for (start..end + 1) |value| {
            const value_as_string = try std.fmt.bufPrint(&buffer, "{}", .{value});
            const is_repeat = has_repeat(value_as_string);
            if (is_repeat) {
                invalid_count += value;
                std.debug.print("    {s} repeats\n", .{value_as_string});
            }
        }
    }

    std.debug.print("Invalid count: {d}\n", .{invalid_count});
    try std.testing.expectEqual(invalid_count, 70187097315);
}
