const std = @import("std");
const data = @embedFile("./day1_input.txt");

const Direction = enum { right, left };

pub fn main() !void {
    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var file = try std.fs.cwd().createFile("day1_output.txt", .{ .truncate = true, .read = false });
    defer file.close();

    var dial_position: i64 = 50;
    var dial_zero_count: u64 = 0;

    while (lines.next()) |line| {
        const direction: Direction = if (line[0] == 'R') .right else .left;
        const start_dial_position = dial_position;
        var turns = try std.fmt.parseInt(i64, line[1..], 0);

        // Any count in excess of 100 does a full rotation
        while (turns > 100) : (turns -= 100) {
            dial_zero_count += 1;
        }

        if (direction == .right) dial_position += turns else dial_position -= turns;

        // Case 1: We passed zero going right
        if (dial_position > 99) {
            dial_position -= 100;
            dial_zero_count += 1;
        }
        // Case 2: We ended on zero
        else if (dial_position == 0) {
            dial_zero_count += 1;
        }
        // Case 3: We passed zero going left
        else if (dial_position < 0) {
            dial_position += 100;
            // Only increment zero count if we were not already on zero to avoid double counting
            if (start_dial_position > 0) dial_zero_count += 1;
        }
    }

    std.debug.print("Zero count: {d}\n", .{dial_zero_count});
    try std.testing.expectEqual(6228, dial_zero_count);
}
