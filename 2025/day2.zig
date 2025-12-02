const std = @import("std");
const data = @embedFile("./day2_input.txt");

const parseInt = std.fmt.parseInt;

pub fn has_repeat(string: []const u8) bool {
    if (string.len == 0) {
        return false;
    }

    if (string.len % 2 != 0) {
        return false;
    }

    const halfway_index = string.len / 2;

    var index: usize = 0;
    while (index < halfway_index) : (index += 1) {
        if (string[index] != string[halfway_index + index]) return false;
    }

    return true;
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
    try std.testing.expectEqual(invalid_count, 54234399924);
}
