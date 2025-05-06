import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart'; // Import model Task
import '../providers/task_provider.dart'; // Import Provider để quản lý danh sách Task
import '../screens/task_form_screen.dart'; // Import màn hình chỉnh sửa Task

// Widget hiển thị từng Task trong danh sách
class TaskItem extends StatelessWidget {
  final Task task;          // Task cần hiển thị
  final VoidCallback onTap; // Hàm xử lý khi bấm vào Task (ví dụ: mở chi tiết)

  TaskItem({required this.task, required this.onTap});

  // Hàm trả về màu sắc tương ứng với độ ưu tiên của Task
  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return Colors.red;     // Ưu tiên cao → đỏ
      case 'Medium':
        return Colors.orange;  // Ưu tiên vừa → cam
      default:
        return Colors.green;   // Ưu tiên thấp hoặc không có → xanh lá
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy đối tượng TaskProvider để gọi hàm xóa/cập nhật task
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Card(
      elevation: 3, // Đổ bóng nhẹ cho đẹp
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: onTap, // Khi bấm vào thẻ này thì gọi hàm onTap

        // Icon tròn nhỏ đại diện cho mức độ ưu tiên
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _getPriorityColor(), // Màu theo độ ưu tiên
          child: Text(
            task.priority[0], // Hiển thị chữ cái đầu của độ ưu tiên (H, M, L)
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        // Tiêu đề công việc
        title: Text(
          task.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),

        // Mô tả, hạn chót và trạng thái công việc
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description, // Mô tả ngắn
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Nếu quá dài thì hiển thị dấu "..."
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text('Due: ${task.dueDate}', style: TextStyle(color: Colors.grey[600])), // Hạn chót
            Text('Status: ${task.status}', style: TextStyle(color: Colors.grey[600])), // Trạng thái (Done/To Do)
          ],
        ),

        // Hàng nút chức năng: sửa, xóa, đánh dấu hoàn thành
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Để Row không chiếm toàn bộ chiều ngang
          children: [
            // Nút chỉnh sửa
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Mở màn hình chỉnh sửa task
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskFormScreen(task: task),
                  ),
                );
              },
            ),

            // Nút xóa
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Gọi hàm xóa task từ Provider
                taskProvider.deleteTask(task.id!);
              },
            ),

            // Nút chuyển đổi trạng thái: Done <-> To Do
            IconButton(
              icon: Icon(
                task.status == 'Done' ? Icons.check_circle : Icons.check_circle_outline,
                color: task.status == 'Done' ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                // Gọi hàm cập nhật trạng thái task
                taskProvider.updateTask(
                  Task(
                    id: task.id,
                    title: task.title,
                    description: task.description,
                    priority: task.priority,
                    status: task.status == 'Done' ? 'To Do' : 'Done', // Đảo trạng thái
                    dueDate: task.dueDate,
                    assignedUserId: task.assignedUserId,
                    createdById: task.createdById,
                    attachmentPath: task.attachmentPath,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}