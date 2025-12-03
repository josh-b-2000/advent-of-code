const std = @import("std");
const data = @embedFile("./day3_input.txt");

const parseInt = std.fmt.parseInt;

inline fn digitCharToInt(c: u8) usize {
    return c - '0';
}

pub fn get_max_number(digit_string: []const u8, size: usize) !usize {
    // No need for edge case checks as we can assume input is well behaved

    var start_index: usize = 0;
    var remaining = size;
    var max_number: usize = 0;

    while (remaining > 0) : (remaining -= 1) {
        var max_digit: u8 = '0';
        var max_digit_index: usize = start_index;
        const end_index = digit_string.len - remaining + 1;

        for (start_index..end_index) |index| {
            if (digit_string[index] > max_digit) {
                max_digit = digit_string[index];
                max_digit_index = index;
            }
        }

        const multiplier = try std.math.powi(usize, 10, remaining - 1);
        max_number += digitCharToInt(max_digit) * multiplier;
        start_index = max_digit_index + 1;
    }

    return max_number;
}

pub fn main() !void {
    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var total: usize = 0;
    while (lines.next()) |line| {
        const max_number = try get_max_number(line, 12);
        total += max_number;

        std.debug.print("{s} => {d}\n", .{ line, max_number });
    }

    std.debug.print("Total: {d}\n", .{total});
    try std.testing.expectEqual(total, 173300819005913);
}
