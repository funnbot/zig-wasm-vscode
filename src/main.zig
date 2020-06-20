const std = @import("std");
const Allocator = std.mem.Allocator;
const allocator: *Allocator = std.heap.page_allocator;

const js = struct {
    extern fn inc(a: i32) i32;
    extern fn stdoutWrite(msg: [*]const u8, len: usize) void;

    var buf: [256]u8 = undefined;
    fn logBuf(comptime fmt: []const u8, args: var) void {
        if (std.fmt.bufPrint(&buf, fmt, args)) |msg| {
            stdoutWrite(msg.ptr, msg.len);
        } else |_| {}
    }

    fn logAlloc(comptime fmt: []const u8, args: var) void {
        if (std.fmt.allocPrint(allocator, fmt, args)) |msg| {
            defer allocator.destroy(msg.ptr);
            stdoutWrite(msg.ptr, msg.len);
        } else |_| {}
    }

    fn logStr(comptime msg: []const u8) void {
        stdoutWrite(msg.ptr, msg.len);
    }
};

export fn hello() void {
    js.logStr("Hello, world!");
}