const std = @import("std");
const data = @embedFile("./day5_input.txt");

const parseInt = std.fmt.parseInt;

const Range = struct { start: usize, end: usize };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Uh oh");
    }

    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var list = std.array_list.Managed(Range).init(allocator);
    defer list.deinit();

    var fresh_count: usize = 0;
    while (lines.next()) |line| {
        var is_range = false;
        for (line) |char| {
            if (char == '-') {
                is_range = true;
                break;
            }
        }

        if (is_range) {
            var range_iter = std.mem.tokenizeAny(u8, line, "-");
            const range_start = try parseInt(usize, range_iter.next().?, 0);
            const range_end = try parseInt(usize, range_iter.next().?, 0);
            std.debug.print("    range: {d} - {d}\n", .{ range_start, range_end });

            try list.append(Range{
                .start = range_start,
                .end = range_end,
            });
            continue;
        }

        const test_val = try parseInt(usize, line, 0);
        var is_fresh = false;
        for (list.items) |range| {
            if (test_val >= range.start and test_val <= range.end) {
                fresh_count += 1;
                is_fresh = true;
                break;
            }
        }
        std.debug.print("    {d} ({s})\n", .{ test_val, if (is_fresh) "yes" else "no" });
    }

    std.debug.print("{d}\n", .{fresh_count});
    try std.testing.expectEqual(558, fresh_count);
}
