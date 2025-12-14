const std = @import("std");
const data = @embedFile("./day5_input.txt");

const parseInt = std.fmt.parseInt;

const Range = struct { start: usize, end: usize };

pub fn rangeSort(_: void, lhs: Range, rhs: Range) bool {
    return lhs.start < rhs.start;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Uh oh");
    }

    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var ranges = std.array_list.Managed(Range).init(allocator);
    defer ranges.deinit();

    while (lines.next()) |line| {
        var is_range = false;
        for (line) |char| {
            if (char == '-') {
                is_range = true;
                break;
            }
        }

        // We only care about the ranges for part 2
        if (!is_range) break;

        var range_iter = std.mem.tokenizeAny(u8, line, "-");
        const range_start = try parseInt(usize, range_iter.next().?, 0);
        const range_end = try parseInt(usize, range_iter.next().?, 0);

        try ranges.append(.{ .start = range_start, .end = range_end });
    }

    std.mem.sort(Range, ranges.items, {}, rangeSort);

    var combined_ranges = std.array_list.Managed(Range).init(allocator);
    defer combined_ranges.deinit();

    var i: usize = 0;
    while (i < ranges.items.len) {
        const range_start: usize = ranges.items[i].start;
        var range_end: usize = ranges.items[i].end;

        var j = i + 1;
        while (j < ranges.items.len and ranges.items[j].start <= range_end) : (j += 1) {
            range_end = if (range_end < ranges.items[j].end)
                ranges.items[j].end
            else
                range_end;
        }
        i = j;

        try combined_ranges.append(.{ .start = range_start, .end = range_end });
    }

    std.debug.print("Combined\n", .{});
    var total: usize = 0;
    for (combined_ranges.items) |range| {
        std.debug.print("  {d} - {d}\n", .{ range.start, range.end });
        total += range.end + 1 - range.start;
    }

    std.debug.print("{d}\n", .{total});
    try std.testing.expectEqual(344813017450467, total);
}
