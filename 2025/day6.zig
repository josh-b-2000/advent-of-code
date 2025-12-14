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
    while (lines.next()) |line| {
        var operators_row = std.mem.tokenizeSequence(u8, line, " ");
        const check = operators_row.peek().?;
        if (check[0] != '*' and check[0] != '+') continue;

        while (operators_row.next()) |operator| {
            length += 1;
            if (operator[0] == '+')
                try operators.append(.add)
            else
                try operators.append(.multiply);
        }
    }

    lines.reset();

    // I don't actually need to do this as I just need the total, but I want to
    // do it for fun
    var values = try allocator.alloc(usize, length);
    defer allocator.free(values);

    // Must be 1 for multiplication and 0 for addition
    for (0..length) |i| {
        if (operators.items[i] == .add) values[i] = 0 else values[i] = 1;
    }

    while (lines.next()) |line| {
        var digits_row = std.mem.tokenizeSequence(u8, line, " ");
        const a = digits_row.peek().?;
        if (a[0] == '*' or a[0] == '+') continue;

        var i: usize = 0;
        while (digits_row.next()) |digits| : (i += 1) {
            const value = try parseInt(usize, digits, 0);
            const op = operators.items[i];
            std.debug.print("  {d} {s} {d}\n", .{
                values[i],
                if (op == .multiply) "*" else "+",
                value,
            });

            if (op == .multiply)
                values[i] *= value
            else
                values[i] += value;
        }
    }

    var total: usize = 0;
    for (0..length) |i| total += values[i];

    std.debug.print("{d}\n", .{total});
    try std.testing.expectEqual(5595593539811, total);
}
