# Claude Code status line

[English](README.md) | **Tiếng Việt**

Status line cho [Claude Code](https://code.claude.com), hiển thị mức sử dụng
context, phần đã dùng của hạn mức 5 giờ và thời điểm hạn mức được làm mới.
Chạy được trên macOS, Linux và Windows.

```
Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)
```

- **Context**: biểu đồ tròn và phần trăm, lần lượt chuyển sang vàng, cam rồi đỏ
  khi context đầy dần
- **Hạn mức sử dụng**: hạn mức 5 giờ kèm thanh tiến độ, có vạch đánh dấu cho biết
  với tốc độ hiện tại bạn có dùng hết trước khi hạn mức được làm mới hay không
- **Thời điểm làm mới**: hiển thị thời gian đếm ngược, giờ làm mới, hoặc cả hai
- **Năm preset** để bắt đầu, bật/tắt được từng phần, và dễ thay đổi chỉ bằng cách
  nhờ Claude Code

Không cần cài thêm ứng dụng nào và script không truy cập mạng. Claude Code vốn
đã gửi số liệu sử dụng cho status line; script chỉ định dạng lại để hiển thị.

## Chọn phiên bản

| Bạn dùng | Thư mục | Cần có |
|---|---|---|
| macOS, Linux hoặc WSL | [`mac/`](mac/) | bash và `jq` (có sẵn từ macOS 15) |
| Windows | [`windows/`](windows/) | Windows PowerShell 5.1 (có sẵn) hoặc PowerShell 7 |

Mỗi thư mục có README riêng, gồm các bước cài đặt, ví dụ hiển thị của từng preset,
toàn bộ tùy chọn và cách khắc phục sự cố. Người dùng Windows cũng có thể tải
`windows/claude-statusline-windows.zip`.

Phần hạn mức sử dụng yêu cầu gói Claude Pro hoặc Max. Nếu bạn dùng API key, các
phần còn lại vẫn hiển thị bình thường.

## Cài đặt bằng Claude Code

Cách nhanh nhất là để Claude Code cài giúp. Tải repo này về, mở Claude Code rồi
dán một trong hai yêu cầu dưới đây, thay đường dẫn bằng nơi bạn đã lưu repo:

**macOS / Linux**

> Cài status line từ `~/Downloads/claude-statusline/mac/statusline.sh`:
> chép file vào `~/.claude/statusline.sh`, sau đó đặt `statusLine` trong
> `~/.claude/settings.json` thành `{"type": "command", "command": "bash ~/.claude/statusline.sh", "refreshInterval": 60}`.
> Giữ nguyên các thiết lập khác của tôi và chạy thử với dữ liệu mẫu để tôi xem kết quả.

**Windows**

> Cài status line từ `C:\Users\<you>\Downloads\claude-statusline\windows\statusline.ps1`:
> chép file vào `C:\Users\<you>\.claude\statusline.ps1`, sau đó đặt `statusLine`
> trong `settings.json` của Claude Code để chạy
> `powershell -NoProfile -ExecutionPolicy Bypass -File "C:/Users/<you>/.claude/statusline.ps1"`
> với `"refreshInterval": 60`. Dùng dấu gạch chéo `/` trong đường dẫn và giữ dấu
> ngoặc kép bao quanh đường dẫn. Giữ nguyên các thiết lập khác của tôi và chạy thử với dữ
> liệu mẫu để tôi xem kết quả.

Hoặc làm theo các bước cài đặt thủ công trong README của từng thư mục.

## Preset

Chọn bố cục ban đầu bằng cách sửa một dòng ở đầu script:

| Preset | Hiển thị |
|---|---|
| `classic` (mặc định) | `Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 6:30 PM` |
| `countdown` | `Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)` |
| `minimal` | `◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m` |
| `full` | thêm nhánh git, nhãn effort và hạn mức theo tuần |
| `plain` | `Me │ Opus 5.5 │ high │ C: 30% │ L: 23% → 2h 15m (6:30 PM)`, dành cho font không có các ký hiệu trên |

Sau đó bạn có thể tinh chỉnh từng phần: nhãn, màu và ngưỡng đổi màu, định dạng
24 giờ, biểu tượng đếm ngược, hạn mức theo tuần cùng nhiều tùy chọn khác. Hoặc chỉ cần
nhờ Claude Code, chẳng hạn: "đổi preset của status line sang minimal và hiển thị
hạn mức theo tuần". README của từng thư mục có thêm nhiều gợi ý khác, ví dụ hiển
thị chi phí của phiên làm việc.

## Quyền riêng tư

Script chỉ đọc dữ liệu phiên làm việc mà Claude Code truyền vào mỗi lần làm mới,
rồi in ra một dòng. Không truy cập mạng, không ghi file và không lưu lại gì.
Khi bật tùy chọn nhánh git, script chạy thêm lệnh `git` để đọc tên nhánh.
