# Claude Code status line cho Windows

[English](README.md) | **Tiếng Việt**

Status line viết bằng PowerShell cho Claude Code, hiển thị mức sử dụng context,
hạn mức sử dụng 5 giờ và thời điểm hạn mức được làm mới. Bạn chọn một trong năm
bố cục có sẵn, sau đó tự tinh chỉnh hoặc nhờ Claude Code thay đổi giúp.

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
| `→ ⧗ 2h 15m (6:30 PM)` | Thời điểm hạn mức được làm mới: thời gian còn lại và giờ địa phương. Bạn có thể chỉ hiển thị một trong hai (xem `$ResetStyle`) |

Không cần cài thêm ứng dụng nào. Claude Code gửi số liệu sử dụng trực tiếp cho
script status line.

## Yêu cầu

- Windows 10 hoặc 11 với Windows PowerShell 5.1 (có sẵn) hoặc PowerShell 7
- Claude Code, đăng nhập bằng tài khoản Claude Pro hoặc Max. Nếu dùng API key,
  phần hạn mức sẽ hiển thị `~`, vì Claude Code chỉ báo số liệu sử dụng cho các
  gói đăng ký
- Nên dùng Windows Terminal. Cửa sổ console cũ có thể thiếu font cho các ký hiệu
  của thanh tiến độ

## Cài đặt

1. Chép `statusline.ps1` vào thư mục Claude của bạn. Trong PowerShell, tại thư
   mục chứa script, chạy:

   ```powershell
   Copy-Item .\statusline.ps1 "$env:USERPROFILE\.claude\"
   ```

2. Mở `C:\Users\<you>\.claude\settings.json` và thêm (hoặc thay thế) mục
   `statusLine`. Thay `<you>` bằng tên người dùng Windows của bạn:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:/Users/<you>/.claude/statusline.ps1\"",
       "refreshInterval": 60
     }
   }
   ```

   - Giữ dấu gạch chéo `/` trong đường dẫn. Nếu máy có Git Bash, Claude Code sẽ
     chạy lệnh qua Git Bash, mà Git Bash lại bỏ các dấu gạch chéo ngược `\`, khiến
     lệnh thất bại mà không báo lỗi.
   - Giữ dấu `\"` bao quanh đường dẫn, để tên người dùng có dấu cách, chẳng hạn
     `C:/Users/John Smith/...`, vẫn chạy được.
   - Cần `-ExecutionPolicy Bypass` vì mặc định Windows chặn các script chưa được
     ký. Tùy chọn này chỉ áp dụng cho riêng script này.
   - `refreshInterval` chạy lại script mỗi 60 giây, nhờ đó thời gian đếm ngược vẫn
     chạy khi bạn không thao tác.

3. Khởi động lại Claude Code.

Hoặc để Claude Code làm giúp bước 1 và 2: xem mục "Cài đặt bằng Claude Code"
trong [README chính](../README.vi.md).

Phần hạn mức hiển thị `~` cho đến khi Claude trả lời lần đầu trong phiên. Đây là
điều bình thường, vì Claude Code chỉ nhận được số liệu sử dụng sau lần trả lời
đầu tiên.

## Chọn preset

Mở `statusline.ps1` và đặt `$Preset` ở gần đầu file:

```powershell
$Preset = 'countdown'
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
| `$ShowDirectory`, `$ShowModel`, `$ShowEffort` | `$true` | `$true` | `$false` | `$true` | `$true` |
| `$ShowBranch`, `$ShowWeekly` | `$false` | `$false` | `$false` | `$true` | `$false` |
| `$ShowContextIcon`, `$ShowBar` | `$true` | `$true` | `$true` | `$true` | `$false` |
| `$ResetStyle` | `'time'` | `'both'` | `'countdown'` | `'both'` | `'both'` |
| `$CountdownIcon` | `0x29D7` (⧗) | `0x29D7` | `0x29D7` | `0x29D7` | `0` (không có) |
| `$ShowContextLabel`, `$ShowLimitLabel` | `$true` | `$false` | `$false` | `$true` | `$true` |
| `$ShowEffortLabel` | `$false` | `$false` | `$false` | `$true` | `$false` |

## Tinh chỉnh

Ngay dưới `$Preset` là khối `$MyOptions` liệt kê mọi tùy chọn, tất cả đều đang bị
comment. Bỏ comment một dòng và đổi giá trị để ghi đè lên preset:

```powershell
$MyOptions = {
    $ShowWeekly       = $true           # 7-day usage limit
    $LimitSteps       = @(60, 80, 95)   # limit % where the color turns yellow, orange, red
    ...
}
```

| Tùy chọn | Giá trị | Tác dụng |
|---|---|---|
| `$ShowDirectory` | `$true` / `$false` | Tên thư mục |
| `$ShowBranch` | `$true` / `$false` | Nhánh git (cần có Git trong PATH) |
| `$ShowModel` | `$true` / `$false` | Tên model |
| `$ShowEffort` | `$true` / `$false` | Mức suy luận (effort) |
| `$ShowContext` | `$true` / `$false` | Phần trăm context |
| `$ShowContextIcon` | `$true` / `$false` | Biểu đồ tròn trước phần trăm context |
| `$ShowLimit` | `$true` / `$false` | Hạn mức sử dụng 5 giờ |
| `$ShowWeekly` | `$true` / `$false` | Hạn mức theo tuần (7 ngày), có thanh tiến độ và thời điểm làm mới riêng |
| `$ShowBar` | `$true` / `$false` | Thanh tiến độ |
| `$ShowPace` | `$true` / `$false` | Vạch tốc độ trên thanh tiến độ |
| `$ShowReset` | `$true` / `$false` | Thời điểm hạn mức được làm mới |
| `$ResetStyle` | `'time'` / `'countdown'` / `'both'` | `→ 6:30 PM`, `→ ⧗ 2h 15m`, hoặc `→ ⧗ 2h 15m (6:30 PM)` |
| `$CountdownIcon` | `0x29D7` ⧗, `0x29D6` ⧖, `0x21BB` ↻, `0` để ẩn | Ký hiệu trước thời gian đếm ngược, viết dưới dạng mã ký tự (xem bên dưới) |
| `$Use24Hour` | `$true` / `$false` | `18:30` thay vì `6:30 PM` |
| `$LimitSteps` | ba số, ví dụ `@(50, 75, 90)` | Các mốc phần trăm hạn mức để chuyển màu vàng, cam, đỏ. Thanh hạn mức theo tuần cũng dùng các mốc này. Nếu danh sách không có đúng ba số, script dùng giá trị mặc định |
| `$ContextSteps` | ba số, ví dụ `@(50, 70, 80)` | Các mốc phần trăm context để chuyển màu vàng, cam, đỏ. Nếu danh sách không có đúng ba số, script dùng giá trị mặc định |
| `$ShowEffortLabel` | `$true` / `$false` | Nhãn `Effort:` trước mức suy luận |
| `$ShowContextLabel` | `$true` / `$false` | Nhãn `C:` trước phần trăm context |
| `$ShowLimitLabel` | `$true` / `$false` | Nhãn `L:` trước hạn mức 5 giờ |
| `$ShowWeeklyLabel` | `$true` / `$false` | Nhãn `Weekly:` trước hạn mức theo tuần |
| `$ShowResetLabel` | `$true` / `$false` | Nhãn `Reset:` trước giờ làm mới hạn mức 5 giờ, hoặc `Reset in` trước thời gian đếm ngược |

Các ký hiệu được khai báo bằng mã ký tự như `0x29D7` vì Windows PowerShell 5.1
đọc sai các ký hiệu gõ trực tiếp vào script nếu file được lưu không có BOM. Cũng vì lý do
đó, bản thân script chỉ dùng ký tự ASCII.

Thay đổi có hiệu lực ở lần làm mới tiếp theo của status line, không cần khởi
động lại.

## Tùy biến bằng Claude Code

Bạn không cần tự sửa script. Mở Claude Code và mô tả điều bạn muốn. Hãy nêu rõ
tên file để Claude sửa chính script này thay vì viết một script mới:

- "Đổi preset trong `~/.claude/statusline.ps1` sang minimal"
- "Trong `~/.claude/statusline.ps1`, hiển thị hạn mức theo tuần và nhánh git"
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
- Nhắc Claude giữ script chỉ dùng ký tự ASCII, để Windows PowerShell 5.1 vẫn đọc
  đúng.
- Lệnh `/statusline` của Claude Code cũng nhận mô tả bằng lời, ví dụ
  `/statusline show the model and context %`, nhưng lệnh này tạo một status line
  mới chứ không sửa script này.

## Chạy thử không cần Claude Code

Dán đoạn sau vào PowerShell. Đoạn này gửi dữ liệu mẫu với thời điểm làm mới là 2
giờ 15 phút kể từ bây giờ:

```powershell
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$reset = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() + 8100
$json = '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"high"},"workspace":{"current_dir":"C:/Users/me/Me"},"context_window":{"used_percentage":30},"rate_limits":{"five_hour":{"used_percentage":23,"resets_at":' + $reset + '}}}'
$json | powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\statusline.ps1"
```

Với preset `classic`, bạn sẽ thấy một dòng có màu tương tự
`Me │ Opus 5.5 │ high │ C: ◔ 30% │ L: 23% ▓▓░░░░┃░░░ → 10:45 PM`, với giờ làm mới
tùy theo thời điểm bạn chạy. Lệnh đầu tiên chuyển cửa sổ PowerShell hiện tại sang
UTF-8 để các ký hiệu hiển thị đúng; Claude Code không cần dòng này. Nếu bạn thấy
các ký tự lạ như `[0;34m` thay vì màu, hãy chạy thử trong Windows Terminal. Cửa
sổ console cũ không hiển thị màu, nhưng status line trong Claude Code vẫn có
màu.

## Khắc phục sự cố

| Vấn đề | Cách xử lý |
|---|---|
| Status line trống | Kiểm tra xem đường dẫn trong `settings.json` đã dùng `/` và trỏ đúng file chưa. Chạy lệnh thử ở trên để xem script có tự chạy được không |
| Hạn mức hiển thị `~` | Chờ Claude trả lời lần đầu. Nếu vẫn vậy, kiểm tra lại xem bạn đang đăng nhập bằng gói Pro/Max (`/status` trong Claude Code) chứ không phải API key |
| Thời gian đếm ngược đứng yên khi không thao tác | Thêm `"refreshInterval": 60` vào mục `statusLine` |
| Thanh tiến độ, biểu đồ tròn hoặc đồng hồ cát hiện thành ô vuông hoặc `?` | Dùng Windows Terminal với font như Cascadia Mono, hoặc đặt `$Preset = 'plain'` |
| Giờ làm mới bị sai | Script dùng múi giờ của Windows. Kiểm tra múi giờ trong Windows Settings > Time & language |
| Lỗi "running scripts is disabled" | Kiểm tra xem lệnh đã có `-ExecutionPolicy Bypass` chưa. Trên máy công ty, Group Policy do quản trị viên đặt có thể vẫn chặn script; hãy hỏi bộ phận IT |
| Sửa xong nhưng không thấy thay đổi | Kiểm tra xem dòng bạn sửa đã được bỏ comment trong `$MyOptions` chưa |

## Ghi chú

- Đã chạy thử với PowerShell 7.6: qua 96 tổ hợp preset và dữ liệu đầu vào, kết
  quả trùng khớp hoàn toàn với bản macOS, kể cả màu sắc. Script chưa được chạy
  trên Windows thật hay trên Windows PowerShell 5.1. Nếu có lỗi, hãy chạy lệnh
  thử ở trên và xem thông báo lỗi.
- Script không truy cập mạng và không đọc file nào, chỉ đọc dữ liệu phiên
  làm việc mà Claude Code truyền vào rồi in ra một dòng. Khi đặt
  `$ShowBranch = $true`, script chạy thêm `git` để đọc tên nhánh.
