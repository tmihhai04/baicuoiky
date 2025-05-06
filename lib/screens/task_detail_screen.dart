import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  // Constructor nhận vào một đối tượng Task để hiển thị chi tiết
  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar là thanh tiêu đề phía trên cùng
      appBar: AppBar(
        title: Text(
          task.title, // Hiển thị tiêu đề của task
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Nền gradient cho AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5, // Đổ bóng dưới AppBar
        shadowColor: Colors.black45,
      ),

      // Thân giao diện chính
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Hiển thị mô tả
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.description, color: Colors.white70),
                  title: Text(
                    'Description: ${task.description}', // Mô tả của task
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Hiển thị độ ưu tiên
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.flag, color: Colors.white70),
                  title: Text(
                    'Priority: ${task.priority}', // Độ ưu tiên của task
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Hiển thị trạng thái
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Colors.white70),
                  title: Text(
                    'Status: ${task.status}', // Trạng thái: Done / Pending
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Hiển thị ngày đến hạn
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.white70),
                  title: Text(
                    'Due Date: ${task.dueDate}', // Ngày cần hoàn thành
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Hiển thị người được giao task
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: Colors.white70),
                  title: Text(
                    'Assigned User ID: ${task.assignedUserId}', // ID người được giao
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Nếu có file đính kèm thì hiển thị
              if (task.attachmentPath != null)
                Card(
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.attach_file, color: Colors.white70),
                    title: Text(
                      'Attachment: ${task.attachmentPath}', // Đường dẫn tệp đính kèm
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}