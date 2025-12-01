const std = @import("std");
const data = @embedFile("./day1_input.txt");

const Direction = enum { right, left };

pub fn main() !void {
    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var dialPosition: i64 = 50;
    var dialZeroCount: u64 = 0;

    while (lines.next()) |line| {
        const direction: Direction = if (line[0] == 'R') .right else .left;
        const turns: i64 = try std.fmt.parseInt(i64, line[1..], 0);

        if (direction == .right) dialPosition += turns else dialPosition -= turns;

        while (dialPosition > 99) dialPosition -= 100;
        while (dialPosition < 0) dialPosition += 100;

        std.debug.print("{s} {d} => {d}", .{ @tagName(direction), turns, dialPosition });
        if (dialPosition == 0) {
            dialZeroCount += 1;
            std.debug.print(" - added\n", .{});
        } else {
            std.debug.print("\n", .{});
        }
    }

    std.debug.print("Zero count: {d}\n", .{dialZeroCount});
}
