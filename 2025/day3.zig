const std = @import("std");
const data = @embedFile("./day3_input.txt");

const parseInt = std.fmt.parseInt;

inline fn digitCharToInt(c: u8) usize {
    return c - '0';
}

pub fn get_max_number(digit_string: []const u8) usize {
    const len = digit_string.len;
    if (len < 2) return 0;

    if (len == 2) {
        return digitCharToInt(digit_string[0]) * 10 + digitCharToInt(digit_string[1]);
    }

    var max_base: usize = 0;
    var max_number: usize = 0;
    for (0..len - 1) |index_1| {
        const base = digitCharToInt(digit_string[index_1]) * 10;

        if (base < max_base) continue else max_base = base;

        for (index_1 + 1..len) |index_2| {
            const number = base + digitCharToInt(digit_string[index_2]);
            if (number > max_number) max_number = number;
        }
    }

    return max_number;
}

pub fn main() !void {
    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var total: usize = 0;
    while (lines.next()) |line| {
        const max_number = get_max_number(line);
        total += max_number;

        std.debug.print("{s} => {d}\n", .{ line, max_number });
    }

    std.debug.print("Total: {d}\n", .{total});
    try std.testing.expectEqual(total, 17452);
}
