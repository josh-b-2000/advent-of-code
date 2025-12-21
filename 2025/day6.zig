const std = @import("std");
const data = @embedFile("./day6_input.txt");

const parseInt = std.fmt.parseInt;

const Operation = enum { multiply, add };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Uh oh");
    }

    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var operators = std.array_list.Managed(Operation).init(allocator);
    defer operators.deinit();

    var length: usize = 0;
    var height: usize = 0;
    while (lines.next()) |line| {
        var operators_row = std.mem.tokenizeSequence(u8, line, " ");
        const check = operators_row.peek().?;
        height += 1;
        if (check[0] != '*' and check[0] != '+') continue;

        height -= 1; // remove counting operator row
        while (operators_row.next()) |operator| {
            length += 1;
            if (operator[0] == '+')
                try operators.append(.add)
            else
                try operators.append(.multiply);
        }
    }

    lines.reset();

    var max_lengths = try allocator.alloc(usize, length);
    defer allocator.free(max_lengths);
    for (0..length) |index|
        max_lengths[index] = 0;

    while (lines.next()) |line| {
        var digits_row = std.mem.tokenizeSequence(u8, line, " ");
        const a = digits_row.peek().?;
        if (a[0] == '*' or a[0] == '+') continue;

        var i: usize = 0;
        while (digits_row.next()) |value| : (i += 1) {
            if (value.len > max_lengths[i]) max_lengths[i] = value.len;
        }
    }

    lines.reset();

    var totals = try allocator.alloc(usize, length);
    defer allocator.free(totals);

    for (operators.items, 0..) |operator, column| {
        const max_length = max_lengths[column];
        totals[column] = if (operator == .add) 0 else 1;

        // Reset column totals
        var column_totals = try allocator.alloc(usize, max_length);
        defer allocator.free(column_totals);
        for (0..max_length) |i| column_totals[i] = 0;

        var start_index: usize = 0;
        for (0..column) |i| start_index += max_lengths[i] + 1;

        var row: usize = 0;
        while (lines.next()) |line| : (row += 1) {
            if (row == height) continue;

            for (0..max_length) |i| {
                const index = start_index + i;
                if (index >= line.len) break; // some lines are not full length

                const char = line[index];
                if (char == ' ') continue;

                const value: usize = char - '0';

                column_totals[i] = column_totals[i] * 10 + value;
            }
        }

        std.debug.print("  {d}: ", .{column});
        for (column_totals) |column_total| {
            std.debug.print("{d} {s} ", .{ column_total, if (operator == .add) "+" else "*" });
            if (operator == .add)
                totals[column] += column_total
            else
                totals[column] *= column_total;
        }
        std.debug.print("\n", .{});

        lines.reset();
    }

    var total: usize = 0;
    for (totals) |t| total += t;

    std.debug.print("{d}\n", .{total});
    try std.testing.expectEqual(10153315705125, total);
}
