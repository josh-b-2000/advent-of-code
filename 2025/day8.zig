const std = @import("std");
const data = @embedFile("./day8_input.txt");

const parseInt = std.fmt.parseInt;

// Need a k-d tree for quick traversal of k nearest neighbours
// Maybe I just compute distance between all points?

const Vec = struct {
    x: isize,
    y: isize,
    z: isize,
    fn distance(self: *const Vec, other: *const Vec) usize {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        const dz = self.z - other.z;
        return @intCast(dx * dx + dy * dy + dz * dz);
    }
};

const Edge = struct { distance: usize, index_1: usize, index_2: usize };

const Edges = struct {
    edges: *[]Edge,
    size: usize,
    _set: usize = 0,
    _sorted: usize = 0,
    fn append(self: *Edges, edge: Edge) void {
        if (self._set >= self.size) return;

        self.edges.*[self._set] = edge;
        self._set += 1;
    }
    fn bubble_next(self: *Edges) ?Edge {
        if (self._sorted >= self.size) return null;

        const end_index = self.size - self._sorted - 1;
        for (0..end_index) |i| {
            if (self.edges.*[i].distance < self.edges.*[i + 1].distance) {
                const tmp = self.edges.*[i];
                self.edges.*[i] = self.edges.*[i + 1];
                self.edges.*[i + 1] = tmp;
            }
        }

        self._sorted += 1;
        return self.edges.*[end_index];
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) @panic("Uh oh");
    }

    var nodes = std.array_list.Managed(Vec).init(allocator);
    defer nodes.deinit();

    var lines = std.mem.tokenizeSequence(u8, data, "\n");

    var i_line: usize = 0;
    while (lines.next()) |line| : (i_line += 1) {
        std.debug.print("{d}: {s}\n", .{ i_line, line });

        var coords = std.mem.tokenizeSequence(u8, line, ",");
        const x = try parseInt(isize, coords.next().?, 0);
        const y = try parseInt(isize, coords.next().?, 0);
        const z = try parseInt(isize, coords.next().?, 0);

        try nodes.append(.{ .x = x, .y = y, .z = z });
    }

    // Number of combinations = N choose 2 (where N = number of nodes)
    const edge_size: usize = nodes.items.len * (nodes.items.len - 1) / 2;

    var edges_list = try allocator.alloc(Edge, edge_size);
    defer allocator.free(edges_list);

    var edges = Edges{ .edges = &edges_list, .size = edge_size };

    for (nodes.items, 0..) |a, a_index| {
        for (nodes.items, 0..) |b, b_index| {
            if (b_index >= a_index) continue;

            const distance = a.distance(&b);
            const new_edge: Edge = .{ .distance = distance, .index_1 = a_index, .index_2 = b_index };

            edges.append(new_edge);
        }
    }

    var node_parents = try allocator.alloc(usize, nodes.items.len);
    defer allocator.free(node_parents);

    var node_is_allocated = try allocator.alloc(bool, nodes.items.len);
    defer allocator.free(node_is_allocated);

    // Copied this optimisation from chatgpt - basically, it ensures that we
    // pick the optimal parent node when merging the sets together
    var node_rank = try allocator.alloc(usize, nodes.items.len);
    defer allocator.free(node_rank);

    for (0..nodes.items.len) |i| {
        node_parents[i] = i;
        node_is_allocated[i] = false;
        node_rank[i] = 0;
    }

    // We can update the size of each circuit at each update
    var circuit_size_map = std.hash_map.AutoHashMap(usize, usize).init(allocator);
    defer circuit_size_map.deinit();

    var total: isize = 0;
    while (edges.bubble_next()) |edge| {
        const node_1 = edge.index_1;
        const node_2 = edge.index_2;

        var node_1_parent = node_parents[node_1];
        while (node_1_parent != node_parents[node_1_parent])
            node_1_parent = node_parents[node_1_parent];

        var node_2_parent = node_parents[node_2];
        while (node_2_parent != node_parents[node_2_parent])
            node_2_parent = node_parents[node_2_parent];

        // Already in same set
        if (node_1_parent == node_2_parent) continue;

        var old_parent: usize = 0;
        var new_parent: usize = 0;

        // The problem is this logic not properly merging the sets
        if (node_rank[node_1_parent] > node_rank[node_2_parent]) {
            node_parents[node_2_parent] = node_1_parent;

            old_parent = node_2_parent;
            new_parent = node_1_parent;
        } else if (node_rank[node_1_parent] < node_rank[node_2_parent]) {
            node_parents[node_1_parent] = node_2_parent;

            old_parent = node_1_parent;
            new_parent = node_2_parent;
        } else {
            node_parents[node_2_parent] = node_1_parent;
            node_rank[node_1_parent] += 1;

            old_parent = node_2_parent;
            new_parent = node_1_parent;
        }

        const new_circuit_size: usize = circuit_size_map.get(new_parent) orelse 1;
        const old_circuit_size: usize = circuit_size_map.get(old_parent) orelse 1;

        if (new_circuit_size + old_circuit_size == nodes.items.len) {
            const node_1_x = nodes.items[node_1].x;
            const node_2_x = nodes.items[node_2].x;
            total = node_1_x * node_2_x;
            break;
        }

        _ = circuit_size_map.remove(old_parent);
        try circuit_size_map.put(new_parent, new_circuit_size + old_circuit_size);
    }

    std.debug.print("{d}\n", .{total});
    try std.testing.expectEqual(274150525, total);
}
