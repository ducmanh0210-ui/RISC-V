# Thiết kế bộ xử lý RISC-V 32 bit
Dự án xây dựng bộ xử lý RISC-V 32 bit bằng Verilog HDL, thực hiện tập lệnh theo yêu cầu của giảng viên. 

1. Thành viên nhóm
- Mạnh
- Vân
- Thắng
- Việt
  
2. Mục tiêu
- Tìm hiểu kiến trúc RISC-V và quá trình thực thi lệnh.
- Thiết kế các khối chức năng bằng Verilog HDL.
- Xây dựng đặc tả cho từng khối: chức năng, đầu vào, đầu ra và quy tắc hoạt động.
- Viết testbench để kiểm tra hoạt động của các khối.
- Quan sát và phân tích waveform trên ModelSim.
- Tích hợp các khối thành bộ xử lý thực hiện được tập lệnh yêu cầu.
  
3. Công cụ sử dụng
| Verilog HDL | Mô tả phần cứng |
| Intel Quartus Prime Lite | Quản lý dự án và tổng hợp thiết kế |
| ModelSim | Mô phỏng và kiểm tra waveform |
| GitHub | Lưu trữ mã nguồn, quản lý phiên bản và chia sẻ trong nhóm |

4. Tổ chức mã nguồn
| `rtl/` | Mã nguồn các khối thiết kế |
| `tb/` | Testbench kiểm tra các khối |
| `function`/| Chức năng của module   |
### Các khối thiết kế hiện có
| File | Khối | Chức năng chính |
| `rtl/register_file.v` | Register File | Lưu trữ, đọc và ghi dữ liệu thanh ghi |
| `rtl/alu.v` | ALU | Thực hiện các phép toán số học và logic theo tín hiệu điều khiển |
| `rtl/pc_unit.v` | PC Unit | Lưu địa chỉ lệnh, cập nhật PC tuần tự, giữ PC khi stall và chuyển đến địa chỉ đích khi redirect |
| `rtl/fetch_stage.v` | Fetch Stage | Phục vụ quá trình lấy lệnh và quản lý các tín hiệu liên quan đến PC |
| `rtl/wb_stage.v` | Write-back Stage | Chọn dữ liệu ghi trả từ kết quả ALU, dữ liệu bộ nhớ hoặc PC + 4 |

### Các testbench hiện có
| File | Đối tượng kiểm tra |
| `tb/tb_register_file.v` | Register File |
| `tb/tb_alu.v` | ALU |
| `tb/tb_wb_stage.v` | Write-back Stage |

5. Trạng thái phát triển
Các công việc tiếp theo:
- Hoàn thiện và thống nhất đặc tả giữa các khối.
- Bổ sung testbench cho PC Unit và Fetch Stage.
- Phát triển các khối còn thiếu theo sơ đồ kiến trúc đã thống nhất.
- Hoàn thiện bộ giải mã lệnh, khối tạo immediate và tín hiệu điều khiển.
- Tích hợp bộ nhớ lệnh, bộ nhớ dữ liệu và đường dữ liệu.
- Nếu triển khai pipeline, bổ sung các thanh ghi pipeline và cơ chế xử lý hazard.
- Chạy các chương trình kiểm tra theo tập lệnh yêu cầu.
- Hoàn thiện báo cáo và tài liệu mô phỏng.
  
6. Quy trình mô phỏng
  1. Tải mã nguồn về máy và giữ nguyên cấu trúc `rtl/`, `tb/`.
  2. Mở ModelSim và tạo dự án mô phỏng.
  3. Thêm file thiết kế, các module phụ thuộc và testbench tương ứng.
  4. Biên dịch các file và xử lý lỗi nếu có.
  5. Chọn module testbench làm top-level mô phỏng.
  6. Thêm tín hiệu cần quan sát vào cửa sổ Wave.
  7. Chạy mô phỏng và đối chiếu kết quả với đặc tả.
     
7. Quy tắc làm việc chung
- Đặt mã thiết kế trong `rtl/` và testbench trong `tb/`.
- Tên testbench dùng tiền tố `tb_`.
- Ưu tiên tên file trùng với tên module.
- Dùng hậu tố `_i` cho input và `_o` cho output.
- Ghi rõ độ rộng, ý nghĩa và mức tác động của tín hiệu trong đặc tả.
- Thống nhất các mã điều khiển trước khi kết nối các khối.
- Với logic tổ hợp, gán đầy đủ đầu ra để tránh suy diễn latch.
- Với logic tuần tự theo clock, sử dụng phép gán nonblocking `<=`.
- Khi thay đổi giao diện module, cập nhật các module kết nối và testbench liên quan.
- Mô phỏng lại phần bị ảnh hưởng trước khi đưa thay đổi vào nhánh chính.
- Viết mô tả commit ngắn gọn, nêu rõ nội dung thêm hoặc sửa.

8. Chia sẻ và đóng góp
Repository được sử dụng để các thành viên cùng theo dõi mã nguồn và tiến độ.
Khi cập nhật code, cần ghi rõ:
- Khối được thay đổi.
- Nội dung và lý do thay đổi.
- Các trường hợp đã kiểm tra.
- Lỗi hoặc giới hạn còn tồn tại.
