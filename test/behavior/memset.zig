const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;

test "@memset on array pointers" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_arm) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_sparc64) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_wasm) {
        // TODO: implement memset when element ABI size > 1
        return error.SkipZigTest;
    }

    try testMemsetArray();
    try comptime testMemsetArray();
}

fn testMemsetArray() !void {
    {
        // memset array to non-undefined, ABI size == 1
        var foo: [20]u8 = undefined;
        @memset(&foo, 'A');
        try expect(foo[0] == 'A');
        try expect(foo[11] == 'A');
        try expect(foo[19] == 'A');
    }
    {
        // memset array to non-undefined, ABI size > 1
        var foo: [20]u32 = undefined;
        @memset(&foo, 1234);
        try expect(foo[0] == 1234);
        try expect(foo[11] == 1234);
        try expect(foo[19] == 1234);
    }
}

test "@memset on slices" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_arm) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_sparc64) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_wasm) {
        // TODO: implement memset when element ABI size > 1
        // TODO: implement memset on slices
        return error.SkipZigTest;
    }

    try testMemsetSlice();
    try comptime testMemsetSlice();
}

fn testMemsetSlice() !void {
    {
        // memset slice to non-undefined, ABI size == 1
        var array: [20]u8 = undefined;
        var len = array.len;
        var slice = array[0..len];
        @memset(slice, 'A');
        try expect(slice[0] == 'A');
        try expect(slice[11] == 'A');
        try expect(slice[19] == 'A');
    }
    {
        // memset slice to non-undefined, ABI size > 1
        var array: [20]u32 = undefined;
        var len = array.len;
        var slice = array[0..len];
        @memset(slice, 1234);
        try expect(slice[0] == 1234);
        try expect(slice[11] == 1234);
        try expect(slice[19] == 1234);
    }
}

test "memset with bool element" {
    var buf: [5]bool = undefined;
    @memset(&buf, true);
    try expect(buf[2]);
    try expect(buf[4]);
}

test "memset with 1-byte struct element" {
    const S = struct { x: bool };
    var buf: [5]S = undefined;
    @memset(&buf, .{ .x = true });
    try expect(buf[2].x);
    try expect(buf[4].x);
}

test "memset with 1-byte array element" {
    const A = [1]bool;
    var buf: [5]A = undefined;
    @memset(&buf, .{true});
    try expect(buf[2][0]);
    try expect(buf[4][0]);
}

test "memset with large array element" {
    const A = [128]u64;
    var buf: [5]A = undefined;
    var runtime_known_element = [_]u64{0} ** 128;
    @memset(&buf, runtime_known_element);
    for (buf[0]) |elem| try expect(elem == 0);
    for (buf[1]) |elem| try expect(elem == 0);
    for (buf[2]) |elem| try expect(elem == 0);
    for (buf[3]) |elem| try expect(elem == 0);
    for (buf[4]) |elem| try expect(elem == 0);
}

test "memcpy and memset intrinsics" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_arm) return error.SkipZigTest;
    if (builtin.zig_backend == .stage2_sparc64) return error.SkipZigTest; // TODO

    try testMemcpyMemset();
    try comptime testMemcpyMemset();
}

fn testMemcpyMemset() !void {
    var foo: [20]u8 = undefined;
    var bar: [20]u8 = undefined;

    @memset(&foo, 'A');
    @memcpy(&bar, &foo);

    try expect(bar[0] == 'A');
    try expect(bar[11] == 'A');
    try expect(bar[19] == 'A');
}
