const std = @import("std");
const data = @embedFile("./day7_input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Uh oh");
    }

    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    const length = lines.peek().?.len;

    var beams = try allocator.alloc(usize, length);
    defer allocator.free(beams);

    for (0..length) |i| beams[i] = 0;

    // First line contains the starting beam position
    const first_line = lines.next().?;
    for (first_line, 0..) |char, index| {
        if (char == 'S') {
            beams[index] = 1;
            break;
        }
    }

    while (lines.next()) |line| {
        var curr = try allocator.alloc(usize, length);
        defer allocator.free(curr);

        for (0..length) |i| curr[i] = beams[i];

        for (line, 0..) |char, index| {
            switch (char) {
                '^' => if (curr[index] > 0) {
                    if (index - 1 >= 0) beams[index - 1] += curr[index];
                    if (index + 1 < length) beams[index + 1] += curr[index];

                    beams[index] = 0;
                },
                else => {},
            }
        }

        std.debug.print("{s}\n", .{line});
        for (beams) |b| std.debug.print("{d}", .{b});
        std.debug.print("\n", .{});
    }

    var total: usize = 0;
    for (beams) |b| total += b;

    std.debug.print("{d}\n", .{total});
    try std.testing.expectEqual(1393669447690, total);
}
