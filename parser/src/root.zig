//! Feed-specific, allocation-free XML scanner for the UrWasm RSS ABI.
const std = @import("std");

pub const abi_version: u8 = 1;
pub const header_len: usize = 16;
const max_output = 4 * 1024 * 1024;
const max_text = 64 * 1024;
const max_items = 256;

var heap: [4 * 1024 * 1024]u8 align(16) = undefined;
var heap_next: usize = 0;
var output: [max_output]u8 align(16) = undefined;
var output_len: u32 = 0;

const Kind = enum(u8) { unknown = 0, rss = 1, atom = 2 };
const Status = enum(u8) { ok = 0, unsupported_root = 1, malformed_xml = 2, output_too_large = 3 };
const Capture = enum {
    none,
    feed_title,
    feed_link,
    channel_description,
    channel_language,
    channel_pub_date,
    channel_last_build_date,
    channel_docs,
    channel_generator,
    channel_managing_editor,
    channel_web_master,
    channel_copyright,
    channel_rating,
    channel_ttl,
    channel_category,
    atom_id,
    atom_updated,
    atom_icon,
    atom_logo,
    atom_rights,
    atom_subtitle,
    atom_feed_author,
    atom_feed_contributor,
    item_title,
    item_link,
    item_description,
    item_id,
    item_author,
    item_comments,
    item_pub_date,
    item_category,
    item_source,
    atom_entry_updated,
    atom_entry_published,
    atom_entry_rights,
    atom_entry_author,
    atom_entry_contributor,
    atom_entry_content,
};

const RecordField = struct { scope: u8, tag: u8 };
var record_output: [max_output]u8 = undefined;
var record_output_len: usize = 0;

const Text = struct {
    bytes: [max_text]u8 = undefined,
    len: usize = 0,

    fn clear(self: *Text) void {
        self.len = 0;
    }
    fn slice(self: *const Text) []const u8 {
        return self.bytes[0..self.len];
    }
    fn append(self: *Text, src: []const u8) bool {
        if (src.len > self.bytes.len - self.len) return false;
        @memcpy(self.bytes[self.len..][0..src.len], src);
        self.len += src.len;
        return true;
    }
    fn appendTruncated(self: *Text, src: []const u8) void {
        const room = self.bytes.len - self.len;
        const n = @min(room, src.len);
        if (n == 0) return;
        @memcpy(self.bytes[self.len..][0..n], src[0..n]);
        self.len += n;
    }
};

const Item = struct {
    title: Text = .{},
    link: Text = .{},
    description: Text = .{},
    id: Text = .{},
    author: Text = .{},
    comments: Text = .{},
    pub_date: Text = .{},
    attr1: Text = .{},
    attr2: Text = .{},
    attr3: Text = .{},
    fn clear(self: *Item) void {
        self.title.clear();
        self.link.clear();
        self.description.clear();
        self.id.clear();
        self.author.clear();
        self.comments.clear();
        self.pub_date.clear();
        self.attr1.clear();
        self.attr2.clear();
        self.attr3.clear();
    }
};

const Writer = struct {
    pos: usize,
    failed: bool = false,
    fn put(self: *Writer, src: []const u8) void {
        if (src.len > output.len - self.pos) {
            self.failed = true;
            return;
        }
        @memcpy(output[self.pos..][0..src.len], src);
        self.pos += src.len;
    }
    fn writeU32(self: *Writer, n: u32) void {
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &bytes, n, .little);
        self.put(&bytes);
    }
    fn text(self: *Writer, value: []const u8) void {
        self.writeU32(@intCast(value.len));
        self.put(value);
    }
    fn record(self: *Writer, field: RecordField, owner: u32, value: []const u8) void {
        self.put(&.{ field.scope, field.tag, 1, 0 });
        self.writeU32(owner);
        self.text(value);
    }
};

pub export fn __wbindgen_malloc(len: u32, alignment: u32) u32 {
    const requested = @max(@as(usize, 1), @as(usize, alignment));
    const start = std.mem.alignForward(usize, heap_next, requested);
    const end = std.math.add(usize, start, len) catch return 0;
    if (end > heap.len) return 0;
    heap_next = end;
    return @intCast(@intFromPtr(&heap[start]));
}

pub export fn parse_feed(ptr: u32, len: u32) u32 {
    const body: []const u8 = if (len == 0) &.{} else @as([*]const u8, @ptrFromInt(ptr))[0..len];
    const parsed = parse(body);
    writeHeader(len, parsed.kind, parsed.status, parsed.payload_len);
    return @intCast(@intFromPtr(&output));
}

pub export fn parse_feed_len() u32 {
    return output_len;
}

const ParseResult = struct { kind: Kind, status: Status, payload_len: u32 };

fn parse(body: []const u8) ParseResult {
    var writer = Writer{ .pos = header_len + 12 };
    var kind: Kind = .unknown;
    var status: Status = .ok;
    var feed_title: Text = .{};
    var feed_link: Text = .{};
    var scalar: Text = .{};
    var item: Item = .{};
    var item_count: u32 = 0;
    record_output_len = 0;
    var depth: usize = 0;
    var item_depth: ?usize = null;
    var capture: Capture = .none;
    var stack: [64][64]u8 = undefined;
    var stack_len: [64]u8 = undefined;

    var i: usize = 0;
    while (i < body.len) {
        if (body[i] != '<') {
            const start = i;
            while (i < body.len and body[i] != '<') : (i += 1) {}
            appendDecoded(captureText(capture, &feed_title, &feed_link, &scalar, &item), body[start..i]);
            continue;
        }
        if (std.mem.startsWith(u8, body[i..], "<!--")) {
            const end = std.mem.indexOfPos(u8, body, i + 4, "-->") orelse {
                status = .malformed_xml;
                break;
            };
            i = end + 3;
            continue;
        }
        if (std.mem.startsWith(u8, body[i..], "<![CDATA[")) {
            const end = std.mem.indexOfPos(u8, body, i + 9, "]]>") orelse {
                status = .malformed_xml;
                break;
            };
            captureText(capture, &feed_title, &feed_link, &scalar, &item).appendTruncated(body[i + 9 .. end]);
            i = end + 3;
            continue;
        }
        if (std.mem.startsWith(u8, body[i..], "<?")) {
            const end = std.mem.indexOfPos(u8, body, i + 2, "?>") orelse {
                status = .malformed_xml;
                break;
            };
            i = end + 2;
            continue;
        }
        if (i + 1 < body.len and body[i + 1] == '/') {
            const end = std.mem.indexOfScalarPos(u8, body, i + 2, '>') orelse {
                status = .malformed_xml;
                break;
            };
            const name = localName(trim(body[i + 2 .. end]));
            if (depth == 0 or !std.mem.eql(u8, name, stack[depth - 1][0..stack_len[depth - 1]])) {
                status = .malformed_xml;
                break;
            }
            if (item_depth) |d| if (depth == d and (std.mem.eql(u8, name, "item") or std.mem.eql(u8, name, "entry"))) {
                if (item_count >= max_items) {
                    status = .output_too_large;
                    break;
                }
                writer.text(item.title.slice());
                writer.text(item.link.slice());
                writer.text(item.description.slice());
                writer.text(item.id.slice());
                if (writer.failed) {
                    status = .output_too_large;
                    break;
                }
                item_count += 1;
                item_depth = null;
                capture = .none;
            };
            if (recordField(kind, capture)) |field| {
                const owner = if (field.scope == 2 or field.scope == 4) item_count else 0;
                if (!appendClosedRecord(field, owner, capture, &feed_title, &feed_link, &scalar, &item)) {
                    status = .output_too_large;
                    break;
                }
            }
            if (captureUsesAttrs(capture)) {
                item.attr1.clear();
                item.attr2.clear();
                item.attr3.clear();
            }
            depth -= 1;
            capture = .none;
            i = end + 1;
            continue;
        }
        if (std.mem.startsWith(u8, body[i..], "<!")) {
            const end = std.mem.indexOfScalarPos(u8, body, i + 2, '>') orelse {
                status = .malformed_xml;
                break;
            };
            i = end + 1;
            continue;
        }
        const end = findTagEnd(body, i + 1) orelse {
            status = .malformed_xml;
            break;
        };
        const raw = trim(body[i + 1 .. end]);
        const self_closing = raw.len > 0 and raw[raw.len - 1] == '/';
        const content = if (self_closing) trim(raw[0 .. raw.len - 1]) else raw;
        const name_end = std.mem.indexOfAny(u8, content, " \t\r\n") orelse content.len;
        const name = localName(content[0..name_end]);
        if (depth == 0) {
            if (std.mem.eql(u8, name, "rss") or std.mem.eql(u8, name, "RDF")) kind = .rss else if (std.mem.eql(u8, name, "feed")) kind = .atom else {
                status = .unsupported_root;
                break;
            }
        }
        if (depth >= stack.len or name.len > stack[0].len) {
            status = .malformed_xml;
            break;
        }
        @memcpy(stack[depth][0..name.len], name);
        stack_len[depth] = @intCast(name.len);
        depth += 1;
        if ((kind == .rss and std.mem.eql(u8, name, "item")) or (kind == .atom and std.mem.eql(u8, name, "entry"))) {
            item.clear();
            item_depth = depth;
        }
        if (kind == .atom and std.mem.eql(u8, name, "link")) {
            if (attribute(content[name_end..], "href")) |href| {
                if (item_depth != null) {
                    if (item.link.len == 0) appendDecoded(&item.link, href);
                } else if (feed_link.len == 0) appendDecoded(&feed_link, href);
            }
            if (!appendAtomLinkRecord(item_depth != null, item_count, content[name_end..])) {
                status = .output_too_large;
                break;
            }
        }
        if (kind == .atom and std.mem.eql(u8, name, "category")) {
            if (!appendAtomCategoryRecord(item_depth != null, item_count, content[name_end..])) {
                status = .output_too_large;
                break;
            }
        }
        if (kind == .atom and item_depth != null and std.mem.eql(u8, name, "content")) {
            if (!appendAtomContentRecord(item_count, content[name_end..])) {
                status = .output_too_large;
                break;
            }
        }
        if (kind == .rss and std.mem.eql(u8, name, "enclosure")) {
            if (!appendRssEnclosureRecord(item_count, content[name_end..])) {
                status = .output_too_large;
                break;
            }
        }
        capture = selectCapture(kind, item_depth != null, name, depth, &stack, &stack_len);
        if (captureNeedsScalar(capture)) scalar.clear();
        captureAttrs(capture, content[name_end..], &item);
        if (self_closing) {
            depth -= 1;
            capture = .none;
        }
        i = end + 1;
    }
    if (status == .ok and depth != 0) status = .malformed_xml;
    if (kind == .unknown and status == .ok) status = .unsupported_root;
    if (status != .ok) return .{ .kind = kind, .status = status, .payload_len = 0 };

    writer.put(record_output[0..record_output_len]);
    if (writer.failed) return .{ .kind = kind, .status = .output_too_large, .payload_len = 0 };
    const body_bytes_len = writer.pos - (header_len + 12);
    const item_shift = feed_title.len + feed_link.len;
    if (writer.pos + item_shift > output.len) return .{ .kind = kind, .status = .output_too_large, .payload_len = 0 };
    std.mem.copyBackwards(u8, output[header_len + 12 + item_shift ..][0..body_bytes_len], output[header_len + 12 ..][0..body_bytes_len]);
    var prefix = Writer{ .pos = header_len };
    prefix.text(feed_title.slice());
    prefix.text(feed_link.slice());
    prefix.writeU32(item_count);
    const payload_len = 12 + item_shift + body_bytes_len;
    return .{ .kind = kind, .status = .ok, .payload_len = @intCast(payload_len) };
}

fn appendRecord(field: RecordField, owner: u32, values: []const []const u8) bool {
    if (values.len > 255) return false;
    var required: usize = 8;
    for (values) |value| required += 4 + value.len;
    if (required > record_output.len - record_output_len) return false;
    record_output[record_output_len..][0..4].* = .{ field.scope, field.tag, @intCast(values.len), 0 };
    std.mem.writeInt(u32, record_output[record_output_len + 4 ..][0..4], owner, .little);
    var pos = record_output_len + 8;
    for (values) |value| {
        std.mem.writeInt(u32, record_output[pos..][0..4], @intCast(value.len), .little);
        pos += 4;
        @memcpy(record_output[pos..][0..value.len], value);
        pos += value.len;
    }
    record_output_len += required;
    return true;
}

fn appendClosedRecord(field: RecordField, owner: u32, capture: Capture, feed_title: *Text, feed_link: *Text, scalar: *Text, item: *Item) bool {
    const value = captureText(capture, feed_title, feed_link, scalar, item).slice();
    return switch (capture) {
        .channel_category, .item_category => appendRecord(field, owner, &.{ item.attr1.slice(), value }),
        .item_source => appendRecord(field, owner, &.{ item.attr1.slice(), value }),
        .item_id => if (field.scope == 2) appendRecord(field, owner, &.{ item.attr1.slice(), value }) else appendRecord(field, owner, &.{value}),
        .atom_entry_content => appendRecord(field, owner, &.{ item.attr1.slice(), item.attr2.slice(), value }),
        else => appendRecord(field, owner, &.{value}),
    };
}

fn selectCapture(kind: Kind, in_item: bool, name: []const u8, depth: usize, stack: *const [64][64]u8, stack_len: *const [64]u8) Capture {
    const parent = parentName(depth, stack, stack_len);
    if (!in_item and kind == .rss) {
        if (std.mem.eql(u8, name, "description")) return .channel_description;
        if (std.mem.eql(u8, name, "language")) return .channel_language;
        if (std.mem.eql(u8, name, "pubDate")) return .channel_pub_date;
        if (std.mem.eql(u8, name, "lastBuildDate")) return .channel_last_build_date;
        if (std.mem.eql(u8, name, "docs")) return .channel_docs;
        if (std.mem.eql(u8, name, "generator")) return .channel_generator;
        if (std.mem.eql(u8, name, "managingEditor")) return .channel_managing_editor;
        if (std.mem.eql(u8, name, "webMaster")) return .channel_web_master;
        if (std.mem.eql(u8, name, "copyright")) return .channel_copyright;
        if (std.mem.eql(u8, name, "rating")) return .channel_rating;
        if (std.mem.eql(u8, name, "ttl")) return .channel_ttl;
        if (std.mem.eql(u8, name, "category")) return .channel_category;
    }
    if (!in_item and kind == .atom) {
        if (std.mem.eql(u8, name, "id")) return .atom_id;
        if (std.mem.eql(u8, name, "updated")) return .atom_updated;
        if (std.mem.eql(u8, name, "icon")) return .atom_icon;
        if (std.mem.eql(u8, name, "logo")) return .atom_logo;
        if (std.mem.eql(u8, name, "rights")) return .atom_rights;
        if (std.mem.eql(u8, name, "subtitle")) return .atom_subtitle;
        if (std.mem.eql(u8, name, "name") and parent != null and std.mem.eql(u8, parent.?, "author")) return .atom_feed_author;
        if (std.mem.eql(u8, name, "name") and parent != null and std.mem.eql(u8, parent.?, "contributor")) return .atom_feed_contributor;
    }
    if (std.mem.eql(u8, name, "title")) return if (in_item) .item_title else .feed_title;
    if (std.mem.eql(u8, name, "link") and kind == .rss) return if (in_item) .item_link else .feed_link;
    if (in_item and (std.mem.eql(u8, name, "description") or std.mem.eql(u8, name, "summary"))) return .item_description;
    if (in_item and kind == .atom and std.mem.eql(u8, name, "content")) return .none;
    if (in_item and kind == .rss and std.mem.eql(u8, name, "author")) return .item_author;
    if (in_item and kind == .rss and std.mem.eql(u8, name, "comments")) return .item_comments;
    if (in_item and kind == .rss and std.mem.eql(u8, name, "pubDate")) return .item_pub_date;
    if (in_item and kind == .rss and std.mem.eql(u8, name, "category")) return .item_category;
    if (in_item and kind == .rss and std.mem.eql(u8, name, "source")) return .item_source;
    if (in_item and kind == .atom and std.mem.eql(u8, name, "updated")) return .atom_entry_updated;
    if (in_item and kind == .atom and std.mem.eql(u8, name, "published")) return .atom_entry_published;
    if (in_item and kind == .atom and std.mem.eql(u8, name, "rights")) return .atom_entry_rights;
    if (in_item and kind == .atom and std.mem.eql(u8, name, "name") and parent != null and std.mem.eql(u8, parent.?, "author")) return .atom_entry_author;
    if (in_item and kind == .atom and std.mem.eql(u8, name, "name") and parent != null and std.mem.eql(u8, parent.?, "contributor")) return .atom_entry_contributor;
    if (in_item and ((kind == .rss and std.mem.eql(u8, name, "guid")) or (kind == .atom and std.mem.eql(u8, name, "id")))) return .item_id;
    return .none;
}

fn captureNeedsScalar(capture: Capture) bool {
    return switch (capture) {
        .channel_description, .channel_language, .channel_pub_date, .channel_last_build_date, .channel_docs, .channel_generator, .channel_managing_editor, .channel_web_master, .channel_copyright, .channel_rating, .channel_ttl, .channel_category, .atom_id, .atom_updated, .atom_icon, .atom_logo, .atom_rights, .atom_subtitle, .atom_feed_author, .atom_feed_contributor, .item_category, .item_source, .atom_entry_updated, .atom_entry_published, .atom_entry_rights, .atom_entry_author, .atom_entry_contributor, .atom_entry_content => true,
        else => false,
    };
}

fn captureUsesAttrs(capture: Capture) bool {
    return switch (capture) {
        .channel_category, .item_category, .item_source, .item_id, .atom_entry_content => true,
        else => false,
    };
}

fn recordField(kind: Kind, capture: Capture) ?RecordField {
    return switch (capture) {
        .feed_title => .{ .scope = if (kind == .rss) 1 else 3, .tag = if (kind == .rss) 1 else 2 },
        .feed_link => if (kind == .rss) .{ .scope = 1, .tag = 2 } else null,
        .channel_description => .{ .scope = 1, .tag = 3 },
        .channel_language => .{ .scope = 1, .tag = 4 },
        .channel_pub_date => .{ .scope = 1, .tag = 5 },
        .channel_last_build_date => .{ .scope = 1, .tag = 6 },
        .channel_docs => .{ .scope = 1, .tag = 7 },
        .channel_generator => .{ .scope = 1, .tag = 8 },
        .channel_managing_editor => .{ .scope = 1, .tag = 9 },
        .channel_web_master => .{ .scope = 1, .tag = 10 },
        .channel_copyright => .{ .scope = 1, .tag = 11 },
        .channel_category => .{ .scope = 1, .tag = 12 },
        .channel_ttl => .{ .scope = 1, .tag = 13 },
        .channel_rating => .{ .scope = 1, .tag = 14 },
        .atom_id => .{ .scope = 3, .tag = 1 },
        .atom_updated => .{ .scope = 3, .tag = 3 },
        .atom_feed_author => .{ .scope = 3, .tag = 4 },
        .atom_feed_contributor => .{ .scope = 3, .tag = 6 },
        .atom_icon => .{ .scope = 3, .tag = 8 },
        .atom_logo => .{ .scope = 3, .tag = 9 },
        .atom_rights => .{ .scope = 3, .tag = 10 },
        .atom_subtitle => .{ .scope = 3, .tag = 11 },
        .item_author => .{ .scope = 2, .tag = 4 },
        .item_category => .{ .scope = 2, .tag = 5 },
        .item_comments => .{ .scope = 2, .tag = 6 },
        .item_id => if (kind == .rss) .{ .scope = 2, .tag = 8 } else null,
        .item_pub_date => .{ .scope = 2, .tag = 9 },
        .item_source => .{ .scope = 2, .tag = 10 },
        .atom_entry_updated => .{ .scope = 4, .tag = 3 },
        .atom_entry_author => .{ .scope = 4, .tag = 4 },
        .atom_entry_contributor => .{ .scope = 4, .tag = 6 },
        .atom_entry_published => .{ .scope = 4, .tag = 7 },
        .atom_entry_rights => .{ .scope = 4, .tag = 8 },
        .atom_entry_content => .{ .scope = 4, .tag = 11 },
        else => null,
    };
}

fn captureText(capture: anytype, feed_title: *Text, feed_link: *Text, scalar: *Text, item: *Item) *Text {
    return switch (capture) {
        .feed_title => feed_title,
        .feed_link => feed_link,
        .channel_description, .channel_language, .channel_pub_date, .channel_last_build_date, .channel_docs, .channel_generator, .channel_managing_editor, .channel_web_master, .channel_copyright, .channel_rating, .channel_ttl, .channel_category, .atom_id, .atom_updated, .atom_icon, .atom_logo, .atom_rights, .atom_subtitle, .atom_feed_author, .atom_feed_contributor, .item_category, .item_source, .atom_entry_updated, .atom_entry_published, .atom_entry_rights, .atom_entry_author, .atom_entry_contributor, .atom_entry_content => scalar,
        .item_title => &item.title,
        .item_link => &item.link,
        .item_description => &item.description,
        .item_id => &item.id,
        .item_author => &item.author,
        .item_comments => &item.comments,
        .item_pub_date => &item.pub_date,
        .none => &discard,
    };
}
var discard: Text = .{};

fn captureAttrs(capture: Capture, attrs: []const u8, item: *Item) void {
    switch (capture) {
        .channel_category, .item_category => setAttr(&item.attr1, attrs, "domain"),
        .item_source => setAttr(&item.attr1, attrs, "url"),
        .item_id => setAttr(&item.attr1, attrs, "isPermaLink"),
        .atom_entry_content => {
            setAttr(&item.attr1, attrs, "type");
            setAttr(&item.attr2, attrs, "src");
        },
        else => {},
    }
}

fn setAttr(dst: *Text, attrs: []const u8, name: []const u8) void {
    dst.clear();
    if (attribute(attrs, name)) |value| appendDecoded(dst, value);
}

fn appendRssEnclosureRecord(owner: u32, attrs: []const u8) bool {
    const url = attribute(attrs, "url") orelse return true;
    const length = attribute(attrs, "length") orelse return true;
    const typ = attribute(attrs, "type") orelse return true;
    if (!allDigits(length)) return true;
    return appendRecord(.{ .scope = 2, .tag = 7 }, owner, &.{ url, length, typ });
}

fn appendAtomLinkRecord(in_entry: bool, owner: u32, attrs: []const u8) bool {
    const href = attribute(attrs, "href") orelse return true;
    const rel = attribute(attrs, "rel") orelse "";
    const typ = attribute(attrs, "type") orelse "";
    const hreflang = attribute(attrs, "hreflang") orelse "";
    const title = attribute(attrs, "title") orelse "";
    const length = attribute(attrs, "length") orelse "";
    if (length.len != 0 and !allDigits(length)) return true;
    return appendRecord(.{ .scope = if (in_entry) 4 else 3, .tag = 12 }, if (in_entry) owner else 0, &.{ href, rel, typ, hreflang, title, length });
}

fn appendAtomCategoryRecord(in_entry: bool, owner: u32, attrs: []const u8) bool {
    const term = attribute(attrs, "term") orelse return true;
    const scheme = attribute(attrs, "scheme") orelse "";
    const label = attribute(attrs, "label") orelse "";
    return appendRecord(.{ .scope = if (in_entry) 4 else 3, .tag = 5 }, if (in_entry) owner else 0, &.{ term, scheme, label });
}

fn appendAtomContentRecord(owner: u32, attrs: []const u8) bool {
    const typ = attribute(attrs, "type") orelse "";
    const src = attribute(attrs, "src") orelse "";
    return appendRecord(.{ .scope = 4, .tag = 11 }, owner, &.{ typ, src, "" });
}

fn allDigits(value: []const u8) bool {
    if (value.len == 0) return false;
    for (value) |c| if (!std.ascii.isDigit(c)) return false;
    return true;
}

fn parentName(depth: usize, stack: *const [64][64]u8, stack_len: *const [64]u8) ?[]const u8 {
    if (depth < 2) return null;
    const index = depth - 2;
    return stack[index][0..stack_len[index]];
}

fn appendDecoded(dst: *Text, src: []const u8) void {
    var i: usize = 0;
    while (i < src.len) {
        if (src[i] != '&') {
            dst.appendTruncated(src[i .. i + 1]);
            i += 1;
            continue;
        }
        const semi = std.mem.indexOfScalarPos(u8, src, i, ';') orelse {
            dst.appendTruncated(src[i .. i + 1]);
            i += 1;
            continue;
        };
        const ent = src[i + 1 .. semi];
        const value: ?u21 = if (std.mem.eql(u8, ent, "amp")) '&' else if (std.mem.eql(u8, ent, "lt")) '<' else if (std.mem.eql(u8, ent, "gt")) '>' else if (std.mem.eql(u8, ent, "quot")) '"' else if (std.mem.eql(u8, ent, "apos")) '\'' else numericEntity(ent);
        if (value) |cp| {
            var bytes: [4]u8 = undefined;
            const n = std.unicode.utf8Encode(cp, &bytes) catch {
                dst.appendTruncated(src[i .. semi + 1]);
                i = semi + 1;
                continue;
            };
            dst.appendTruncated(bytes[0..n]);
        } else dst.appendTruncated(src[i .. semi + 1]);
        i = semi + 1;
    }
}

fn numericEntity(ent: []const u8) ?u21 {
    if (ent.len < 2 or ent[0] != '#') return null;
    const base: u8 = if (ent.len > 2 and (ent[1] == 'x' or ent[1] == 'X')) 16 else 10;
    const digits = ent[if (base == 16) 2 else 1..];
    const n = std.fmt.parseInt(u21, digits, base) catch return null;
    return if (std.unicode.utf8ValidCodepoint(n)) n else null;
}

fn findTagEnd(body: []const u8, start: usize) ?usize {
    var i = start;
    var quote: ?u8 = null;
    while (i < body.len) : (i += 1) {
        if (quote) |q| {
            if (body[i] == q) quote = null;
        } else if (body[i] == '\'' or body[i] == '"') quote = body[i] else if (body[i] == '>') return i;
    }
    return null;
}
fn trim(s: []const u8) []const u8 {
    return std.mem.trim(u8, s, " \t\r\n");
}
fn localName(name: []const u8) []const u8 {
    return if (std.mem.lastIndexOfScalar(u8, name, ':')) |i| name[i + 1 ..] else name;
}
fn attribute(raw: []const u8, wanted: []const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < raw.len) {
        while (i < raw.len and std.ascii.isWhitespace(raw[i])) : (i += 1) {}
        const start = i;
        while (i < raw.len and raw[i] != '=' and !std.ascii.isWhitespace(raw[i])) : (i += 1) {}
        const name = localName(raw[start..i]);
        while (i < raw.len and std.ascii.isWhitespace(raw[i])) : (i += 1) {}
        if (i >= raw.len or raw[i] != '=') {
            while (i < raw.len and !std.ascii.isWhitespace(raw[i])) : (i += 1) {}
            continue;
        }
        i += 1;
        while (i < raw.len and std.ascii.isWhitespace(raw[i])) : (i += 1) {}
        if (i >= raw.len or (raw[i] != '\'' and raw[i] != '"')) return null;
        const quote = raw[i];
        i += 1;
        const value_start = i;
        while (i < raw.len and raw[i] != quote) : (i += 1) {}
        if (i >= raw.len) return null;
        const value = raw[value_start..i];
        i += 1;
        if (std.mem.eql(u8, name, wanted)) return value;
    }
    return null;
}

fn writeHeader(input_len: u32, kind: Kind, status: Status, payload_len: u32) void {
    output[0..16].* = .{ 'R', 'S', 'S', 'W', abi_version, @intFromEnum(status), @intFromEnum(kind), 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    std.mem.writeInt(u32, output[8..12], input_len, .little);
    std.mem.writeInt(u32, output[12..16], payload_len, .little);
    output_len = @intCast(header_len + payload_len);
}

test "streams RSS core fields" {
    const r = parse("<rss><channel><title>A &amp; B</title><link>https://x</link><item><title>One</title><link>https://i</link><description><![CDATA[Hello]]></description></item></channel></rss>");
    try std.testing.expectEqual(Kind.rss, r.kind);
    try std.testing.expectEqual(Status.ok, r.status);
    try std.testing.expect(r.payload_len > 20);
}
test "streams Atom core fields" {
    const r = parse("<feed xmlns=\"x\"><title>Feed</title><link href=\"https://f\"/><entry><title>Entry</title><link href=\"https://e\"/><summary>Text</summary></entry></feed>");
    try std.testing.expectEqual(Kind.atom, r.kind);
    try std.testing.expectEqual(Status.ok, r.status);
}
test "appends tagged RSS channel scalars after the fixed core" {
    const r = parse("<rss><channel><title>A</title><link>x</link><description>Desc</description><language>en</language></channel></rss>");
    try std.testing.expectEqual(Status.ok, r.status);
    const records_start = header_len + 12 + 1 + 1;
    const expected = [_]u8{
        1,   1,   1,   0,   0, 0, 0, 0, 1, 0, 0, 0, 'A',
        1,   2,   1,   0,   0, 0, 0, 0, 1, 0, 0, 0, 'x',
        1,   3,   1,   0,   0, 0, 0, 0, 4, 0, 0, 0, 'D',
        'e', 's', 'c', 1,   4, 1, 0, 0, 0, 0, 0, 2, 0,
        0,   0,   'e', 'n',
    };
    try std.testing.expectEqualSlices(u8, &expected, output[records_start .. records_start + expected.len]);
}

test "appends tagged Atom feed scalars after the fixed core" {
    const r = parse("<feed><title>A</title><link href=\"x\"/><id>urn:test</id><rights>All</rights></feed>");
    try std.testing.expectEqual(Status.ok, r.status);
    const records_start = header_len + 12 + 1 + 1;
    const expected = [_]u8{
        3,   2,   1,   0, 0, 0, 0,   0,   1,   0,   0,   0,   'A',
        3,   12,  6,   0, 0, 0, 0,   0,   1,   0,   0,   0,   'x',
        0,   0,   0,   0, 0, 0, 0,   0,   0,   0,   0,   0,   0,
        0,   0,   0,   0, 0, 0, 0,   3,   1,   1,   0,   0,   0,
        0,   0,   8,   0, 0, 0, 'u', 'r', 'n', ':', 't', 'e', 's',
        't', 3,   10,  1, 0, 0, 0,   0,   0,   3,   0,   0,   0,
        'A', 'l', 'l',
    };
    try std.testing.expectEqualSlices(u8, &expected, output[records_start .. records_start + expected.len]);
}
test "rejects malformed XML" {
    const r = parse("<rss><channel></rss>");
    try std.testing.expectEqual(Status.malformed_xml, r.status);
}

test "truncates oversized text fields instead of failing the feed" {
    const long = try std.testing.allocator.alloc(u8, max_text + 1);
    defer std.testing.allocator.free(long);
    @memset(long, 'x');
    const feed = try std.fmt.allocPrint(
        std.testing.allocator,
        "<rss><channel><title>A</title><link>https://x</link><item><title>One</title><link>https://i</link><description>{s}</description></item></channel></rss>",
        .{long},
    );
    defer std.testing.allocator.free(feed);
    const r = parse(feed);
    try std.testing.expectEqual(Kind.rss, r.kind);
    try std.testing.expectEqual(Status.ok, r.status);
}

test "Hacker News snapshot has ordered RSS items" {
    const snapshot = try std.fs.cwd().readFileAlloc(std.testing.allocator, "testdata/hacker-news.rss.xml", 2 * 1024 * 1024);
    defer std.testing.allocator.free(snapshot);
    const r = parse(snapshot);
    try std.testing.expectEqual(Kind.rss, r.kind);
    try std.testing.expectEqual(Status.ok, r.status);
    try std.testing.expect(r.payload_len > 100);
}

test "Simon Willison snapshot has ordered Atom entries" {
    const snapshot = try std.fs.cwd().readFileAlloc(std.testing.allocator, "testdata/simon-willison.atom.xml", 2 * 1024 * 1024);
    defer std.testing.allocator.free(snapshot);
    const r = parse(snapshot);
    try std.testing.expectEqual(Kind.atom, r.kind);
    try std.testing.expectEqual(Status.ok, r.status);
    try std.testing.expect(r.payload_len > 100);
    try validatePayloadRecords(r);
}

fn readTestU32(bytes: []const u8, pos: *usize) !u32 {
    if (pos.* + 4 > bytes.len) return error.Truncated;
    const value = std.mem.readInt(u32, bytes[pos.*..][0..4], .little);
    pos.* += 4;
    return value;
}

fn skipTestText(bytes: []const u8, pos: *usize) !void {
    const len = try readTestU32(bytes, pos);
    if (pos.* + len > bytes.len) return error.Truncated;
    pos.* += len;
}

fn validatePayloadRecords(r: ParseResult) !void {
    const payload = output[header_len..][0..r.payload_len];
    var pos: usize = 0;
    try skipTestText(payload, &pos);
    try skipTestText(payload, &pos);
    const count = try readTestU32(payload, &pos);
    var n: u32 = 0;
    while (n < count) : (n += 1) {
        try skipTestText(payload, &pos);
        try skipTestText(payload, &pos);
        try skipTestText(payload, &pos);
        try skipTestText(payload, &pos);
    }
    while (pos < payload.len) {
        if (pos + 8 > payload.len) return error.TruncatedRecord;
        const value_count = payload[pos + 2];
        pos += 8;
        var i: u8 = 0;
        while (i < value_count) : (i += 1) try skipTestText(payload, &pos);
    }
    try std.testing.expectEqual(payload.len, pos);
}
