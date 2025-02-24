const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    if (args.len != 4) {
        std.debug.print("Usage: {s} <input.csv> <output.csv> <sample_count>\n", .{args[0]});
        return error.InvalidArguments;
    }

    const input_file = args[1];
    const output_file = args[2];
    const sample_count = try std.fmt.parseInt(usize, args[3], 10);

    const in_file = try std.fs.cwd().openFile(input_file, .{});
    defer in_file.close();

    const out_file = try std.fs.cwd().createFile(output_file, .{});
    defer out_file.close();

    var buffered_reader = std.io.bufferedReader(in_file.reader());
    var reader = buffered_reader.reader();

    var buffered_writer = std.io.bufferedWriter(out_file.writer());
    var writer = buffered_writer.writer();

    // Динамический буфер для строк
    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    // Читаем и записываем заголовок
    try reader.streamUntilDelimiter(line.writer(), '\n', null);
    if (line.items.len > 0) {
        try writer.writeAll(line.items);
        try writer.writeByte('\n');
        line.clearRetainingCapacity();
    }

    // Массив для хранения выбранных строк
    var reservoir = try allocator.alloc([]u8, sample_count);
    defer {
        for (reservoir) |l| if (l.len > 0) allocator.free(l);
        allocator.free(reservoir);
    }
    for (reservoir) |*item| item.* = &[_]u8{};

    var line_count: usize = 0;
    var prng = std.rand.DefaultPrng.init(@intCast(std.time.milliTimestamp()));
    const random = prng.random();

    // Читаем строки
    while (true) {
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        if (line_count < sample_count) {
            reservoir[line_count] = try allocator.dupe(u8, line.items);
        } else {
            line_count += 1;
            if (random.float(f32) < @as(f32, @floatFromInt(sample_count)) / @as(f32, @floatFromInt(line_count))) {
                const idx = random.intRangeLessThan(usize, 0, sample_count);
                allocator.free(reservoir[idx]);
                reservoir[idx] = try allocator.dupe(u8, line.items);
            }
        }
        line_count += 1;
        line.clearRetainingCapacity();
    }

    // Записываем результат
    for (reservoir) |l| {
        if (l.len > 0) {
            try writer.writeAll(l);
            try writer.writeByte('\n');
        }
    }

    try buffered_writer.flush();
}

test "basic test" {
    try std.testing.expect(true);
}
