const std = @import("std");
const data = @embedFile("./day4_input.txt");

const parseInt = std.fmt.parseInt;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Uh oh");
    }

    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var map = std.AutoHashMap(usize, u8).init(allocator);
    defer map.deinit();

    const first_line = lines.peek().?;
    const col_count = first_line.len;

    var row_index: usize = 0;
    while (lines.next()) |line| {
        for (line, 0..) |char, col_index| {
            if (char == '@') try map.put(row_index * col_count + col_index, 0);
        }

        row_index += 1;
    }

    var count_valid: usize = 0;
    var iter = map.keyIterator();
    while (iter.next()) |index_ptr| {
        const test_index = index_ptr.*;
        const is_left = test_index % col_count == 0;
        const is_right = (test_index + 1) % col_count == 0;

        var touching_count: usize = 0;

        // Can check vertical independent of top/bottom
        // - Need to be wary of going negative though (integer overflow)
        if (test_index > col_count and map.contains(test_index - col_count)) touching_count += 1;
        if (map.contains(test_index + col_count)) touching_count += 1;

        if (!is_left) {
            if (test_index > col_count and map.contains(test_index - col_count - 1)) touching_count += 1;
            if (map.contains(test_index - 1)) touching_count += 1;
            if (map.contains(test_index + col_count - 1)) touching_count += 1;
        }

        if (!is_right) {
            if (test_index > col_count and map.contains(test_index - col_count + 1)) touching_count += 1;
            if (map.contains(test_index + 1)) touching_count += 1;
            if (map.contains(test_index + col_count + 1)) touching_count += 1;
        }

        if (touching_count < 4) count_valid += 1;
        std.debug.print("\n{d} - {d} ({d})\n", .{ test_index, touching_count, count_valid });
    }

    std.debug.print("\n{d}\n", .{count_valid});
    try std.testing.expectEqual(1457, count_valid);
}
