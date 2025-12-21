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

    var beams = try allocator.alloc(bool, length);
    defer allocator.free(beams);

    for (0..length) |i| beams[i] = false;

    var split_count: usize = 0;
    while (lines.next()) |line| {
        var curr = try allocator.alloc(bool, length);
        defer allocator.free(curr);

        for (0..length) |i| curr[i] = beams[i];

        for (line, 0..) |char, index| {
            switch (char) {
                'S' => beams[index] = true,
                '^' => if (curr[index]) {
                    if (index - 1 >= 0) beams[index - 1] = true;
                    beams[index] = false;
                    if (index + 1 < length) beams[index + 1] = true;
                    split_count += 1;
                },
                else => {},
            }
        }

        std.debug.print("{s}\n", .{line});
        for (beams) |b| std.debug.print("{s}", .{if (b) "|" else " "});
        std.debug.print("\n", .{});
    }

    std.debug.print("{d}\n", .{split_count});
    try std.testing.expectEqual(1516, split_count);
}
