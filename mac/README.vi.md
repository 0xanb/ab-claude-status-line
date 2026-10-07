# Claude Code status line cho macOS và Linux

[English](README.md) | **Tiếng Việt**

Status line viết bằng bash cho Claude Code, hiển thị mức sử dụng context, hạn
mức sử dụng 5 giờ và thời điểm hạn mức được làm mới. Bạn chọn một trong năm bố
cục có sẵn, sau đó tự tinh chỉnh hoặc nhờ Claude Code thay đổi giúp.

```
Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)
```

| Phần | Ý nghĩa |
|---|---|
| `Me` | Thư mục hiện tại |
| `Opus 5.5` | Model |
| `high` | Mức suy luận (effort): `low`, `medium`, `high`, `xhigh` hoặc `max`. Cập nhật khi bạn đổi bằng `/effort`, và được ẩn với những model không hỗ trợ effort |
| `◔ 30%` | Phần context đã dùng, kèm biểu đồ tròn, làm tròn đến một phần tư gần nhất: `○` 0–12%, `◔` 13–37%, `◑` 38–62%, `◕` 63–87%, `●` từ 88% trở lên. Màu xanh lơ (cyan), chuyển vàng từ 50%, cam từ 70%, đỏ từ 80% |
| `23%` | Phần đã dùng của hạn mức 5 giờ. Màu xanh lá, chuyển vàng từ 50%, cam từ 75%, đỏ từ 90% |
| `▓▓░░░░┃░░░` | Thanh hạn mức, cùng màu với phần trăm hạn mức. Vạch `┃` cho biết khung 5 giờ đã trôi qua được bao nhiêu. Màu của vạch thể hiện tốc độ sử dụng: xanh lá hoặc xanh ngọc là ổn, vàng hoặc cam là sắp chạm ngưỡng, đỏ hoặc tím là sẽ dùng hết trước khi hạn mức được làm mới |
| `→ ⧗ 2h 15m (6:30 PM)` | Thời điểm hạn mức được làm mới: thời gian còn lại và giờ địa phương. Bạn có thể chỉ hiển thị một trong hai (xem `RESET_STYLE`) |

Không cần cài thêm ứng dụng nào. Claude Code gửi số liệu sử dụng trực tiếp cho
script status line.

## Yêu cầu

- macOS 15 trở lên, đã có sẵn `jq`. Với macOS cũ hơn, cài bằng `brew install jq`
- Hoặc Linux (kể cả WSL trên Windows) có bash và `jq`, ví dụ cài bằng
  `sudo apt install jq`
- Claude Code, đăng nhập bằng tài khoản Claude Pro hoặc Max. Nếu dùng API key,
  phần hạn mức sẽ hiển thị `~`, vì Claude Code chỉ báo số liệu sử dụng cho các
  gói đăng ký

## Cài đặt

1. Chép `statusline.sh` vào thư mục Claude của bạn:

   ```bash
   cp statusline.sh ~/.claude/statusline.sh
   ```

2. Mở `~/.claude/settings.json` và thêm (hoặc thay thế) mục `statusLine`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline.sh",
       "refreshInterval": 60
     }
   }
   ```

   `refreshInterval` chạy lại script mỗi 60 giây, nhờ đó thời gian đếm ngược vẫn
   chạy khi bạn không thao tác. Nếu thiếu tùy chọn này, status line chỉ được
   vẽ lại khi có hoạt động trong phiên làm việc.

   Nếu bạn đang dùng một status line khác, hãy ghi lại giá trị `command` hiện
   tại để có thể chuyển về khi cần.

3. Khởi động lại Claude Code.

Hoặc để Claude Code làm giúp bước 1 và 2: xem mục "Cài đặt bằng Claude Code"
trong [README chính](../README.vi.md).

Phần hạn mức hiển thị `~` cho đến khi Claude trả lời lần đầu trong phiên. Đây là
điều bình thường, vì Claude Code chỉ nhận được số liệu sử dụng sau lần trả lời
đầu tiên.

## Chọn preset

Mở `~/.claude/statusline.sh` và đặt `PRESET` ở gần đầu file:

```bash
PRESET="countdown"
```

| Preset | Hiển thị | Phù hợp khi |
|---|---|---|
| `classic` (mặc định) | `Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 6:30 PM` | Muốn có nhãn cho từng phần và giờ làm mới hạn mức |
| `countdown` | `Me │ Opus 5.5 │ high │ ◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM)` | Muốn biết còn bao lâu đến lúc làm mới, không cần nhãn |
| `minimal` | `◔ 30% │ 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m` | Cửa sổ hẹp: chỉ context và hạn mức |
| `full` | `Me │ ⎇ main │ Opus 5.5 │ Effort: high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → ⧗ 2h 15m (6:30 PM) │ Weekly: 41% ▓▓▓▓░┃░░░░ → ⧗ 3d 4h (Sat 8:15 PM)` | Muốn xem đầy đủ, kể cả nhánh git và hạn mức theo tuần |
| `plain` | `Me │ Opus 5.5 │ high │ C: 30% │ L: 23% → 2h 15m (6:30 PM)` | Font hiển thị thanh tiến độ, biểu đồ tròn hoặc đồng hồ cát thành ô vuông |

Mỗi preset thay đổi những tùy chọn nào so với `classic`:

| Tùy chọn | `classic` | `countdown` | `minimal` | `full` | `plain` |
|---|---|---|---|---|---|
| `SHOW_DIRECTORY`, `SHOW_MODEL`, `SHOW_EFFORT` | `1` | `1` | `0` | `1` | `1` |
| `SHOW_BRANCH`, `SHOW_WEEKLY` | `0` | `0` | `0` | `1` | `0` |
| `SHOW_CONTEXT_ICON`, `SHOW_BAR` | `1` | `1` | `1` | `1` | `0` |
| `RESET_STYLE` | `time` | `both` | `countdown` | `both` | `both` |
| `COUNTDOWN_ICON` | `⧗` | `⧗` | `⧗` | `⧗` | không có |
| `SHOW_CONTEXT_LABEL`, `SHOW_LIMIT_LABEL` | `1` | `0` | `0` | `1` | `1` |
| `SHOW_EFFORT_LABEL` | `0` | `0` | `0` | `1` | `0` |

## Tinh chỉnh

Ngay dưới `PRESET` là khối `my_options` liệt kê mọi tùy chọn, tất cả đều đang bị
comment. Bỏ comment một dòng và đổi giá trị để ghi đè lên preset:

```bash
my_options() {
  : # keep this line
  SHOW_WEEKLY=1             # 7-day usage limit
  LIMIT_STEPS=(60 80 95)    # limit % where the color turns yellow, orange, red
  ...
}
```

| Tùy chọn | Giá trị | Tác dụng |
|---|---|---|
| `SHOW_DIRECTORY` | `1` / `0` | Tên thư mục |
| `SHOW_BRANCH` | `1` / `0` | Nhánh git |
| `SHOW_MODEL` | `1` / `0` | Tên model |
| `SHOW_EFFORT` | `1` / `0` | Mức suy luận (effort) |
| `SHOW_CONTEXT` | `1` / `0` | Phần trăm context |
| `SHOW_CONTEXT_ICON` | `1` / `0` | Biểu đồ tròn trước phần trăm context |
| `SHOW_LIMIT` | `1` / `0` | Hạn mức sử dụng 5 giờ |
| `SHOW_WEEKLY` | `1` / `0` | Hạn mức theo tuần (7 ngày), có thanh tiến độ và thời điểm làm mới riêng |
| `SHOW_BAR` | `1` / `0` | Thanh tiến độ |
| `SHOW_PACE` | `1` / `0` | Vạch tốc độ trên thanh tiến độ |
| `SHOW_RESET` | `1` / `0` | Thời điểm hạn mức được làm mới |
| `RESET_STYLE` | `"time"` / `"countdown"` / `"both"` | `→ 6:30 PM`, `→ ⧗ 2h 15m`, hoặc `→ ⧗ 2h 15m (6:30 PM)` |
| `COUNTDOWN_ICON` | `"⧗"`, `"⧖"`, `"↻"`, `""` | Ký hiệu trước thời gian đếm ngược; `""` để ẩn |
| `USE_24_HOUR` | `1` / `0` | `18:30` thay vì `6:30 PM` |
| `LIMIT_STEPS` | ba số, ví dụ `(50 75 90)` | Các mốc phần trăm hạn mức để chuyển màu vàng, cam, đỏ. Thanh hạn mức theo tuần cũng dùng các mốc này. Nếu danh sách không có đúng ba số, script dùng giá trị mặc định |
| `CONTEXT_STEPS` | ba số, ví dụ `(50 70 80)` | Các mốc phần trăm context để chuyển màu vàng, cam, đỏ. Nếu danh sách không có đúng ba số, script dùng giá trị mặc định |
| `SHOW_EFFORT_LABEL` | `1` / `0` | Nhãn `Effort:` trước mức suy luận |
| `SHOW_CONTEXT_LABEL` | `1` / `0` | Nhãn `C:` trước phần trăm context |
| `SHOW_LIMIT_LABEL` | `1` / `0` | Nhãn `L:` trước hạn mức 5 giờ |
| `SHOW_WEEKLY_LABEL` | `1` / `0` | Nhãn `Weekly:` trước hạn mức theo tuần |
| `SHOW_RESET_LABEL` | `1` / `0` | Nhãn `Reset:` trước giờ làm mới hạn mức 5 giờ, hoặc `Reset in` trước thời gian đếm ngược |

Thay đổi có hiệu lực ở lần làm mới tiếp theo của status line, không cần khởi
động lại.

## Tùy biến bằng Claude Code

Bạn không cần tự sửa script. Mở Claude Code và mô tả điều bạn muốn. Hãy nêu rõ
tên file để Claude sửa chính script này thay vì viết một script mới:

- "Đổi preset trong `~/.claude/statusline.sh` sang minimal"
- "Trong `~/.claude/statusline.sh`, hiển thị hạn mức theo tuần và nhánh git"
- "Cho hạn mức chuyển vàng ở 60%, cam ở 80% và đỏ ở 95%"
- "Dùng ↻ thay cho đồng hồ cát, và hiển thị giờ dạng 24 giờ"

Claude Code gửi cho status line nhiều dữ liệu hơn những gì script này đang hiển
thị, nên bạn cũng có thể yêu cầu thêm phần mới:

- "Thêm chi phí của phiên làm việc" (`cost.total_cost_usd`)
- "Hiển thị số dòng đã thêm và đã xóa trong phiên" (`cost.total_lines_added`, `cost.total_lines_removed`)
- "Hiển thị thời gian phiên làm việc đã chạy" (`cost.total_duration_ms`)
- "Hiển thị tên repo thay cho tên thư mục" (`workspace.repo.name`)
- "Đưa hạn mức theo tuần xuống dòng thứ hai" (mỗi dòng script in ra là một hàng riêng)

Mẹo:

- Hãy nhờ Claude "cho tôi xem trước đã". Claude có thể chạy script với dữ liệu
  mẫu và cho bạn xem kết quả trước khi sửa vào script bạn đang dùng.
- Lệnh `/statusline` của Claude Code cũng nhận mô tả bằng lời, ví dụ
  `/statusline show the model and context %`, nhưng lệnh này tạo một status line
  mới chứ không sửa script này.

## Chạy thử không cần Claude Code

Dán đoạn sau vào Terminal. Đoạn này gửi dữ liệu mẫu với thời điểm làm mới là 2
giờ 15 phút kể từ bây giờ:

```bash
reset=$(( $(date +%s) + 8100 ))
echo '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"high"},"workspace":{"current_dir":"/Users/me/Me"},"context_window":{"used_percentage":30},"rate_limits":{"five_hour":{"used_percentage":23,"resets_at":'$reset'}}}' | bash ~/.claude/statusline.sh
```

Với preset `classic`, bạn sẽ thấy một dòng có màu tương tự
`Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 10:45 PM`, với giờ làm mới
tùy theo thời điểm bạn chạy.

## Khắc phục sự cố

| Vấn đề | Cách xử lý |
|---|---|
| Status line trống | Kiểm tra xem `command` trong `settings.json` đã trỏ đúng file chưa. Chạy lệnh thử ở trên để xem script có tự chạy được không |
| Hiện `statusline: jq not found` | Cài jq: `brew install jq` trên macOS, `sudo apt install jq` trên Ubuntu hoặc Debian |
| Hạn mức hiển thị `~` | Chờ Claude trả lời lần đầu. Nếu vẫn vậy, kiểm tra lại xem bạn đang đăng nhập bằng gói Pro/Max (`/status` trong Claude Code) chứ không phải API key |
| Thời gian đếm ngược đứng yên khi không thao tác | Thêm `"refreshInterval": 60` vào mục `statusLine` |
| Biểu đồ tròn, thanh tiến độ hoặc đồng hồ cát hiển thị sai | Font của terminal không có các ký hiệu này. Thử font khác, hoặc dùng `PRESET="plain"` |
| Sửa xong nhưng không thấy thay đổi | Kiểm tra xem dòng bạn sửa đã được bỏ comment trong `my_options` chưa, và dòng `: # keep this line` vẫn còn |

## Ghi chú

- Đã chạy thử trên macOS 27 với bash 3.2 và jq 1.7.1 có sẵn. Mỗi lần làm mới mất
  khoảng 20 ms.
- Trên Linux, script dùng `date -d` thay cho `date -r` (chỉ có trên macOS). Cách
  dự phòng này mới được kiểm tra bằng một lệnh `date` mô phỏng Linux, chưa chạy
  trên máy Linux thật.
- Script không truy cập mạng và không đọc file nào, chỉ đọc dữ liệu phiên
  làm việc mà Claude Code truyền vào rồi in ra một dòng. Khi đặt
  `SHOW_BRANCH=1`, script chạy thêm `git` để đọc tên nhánh.
